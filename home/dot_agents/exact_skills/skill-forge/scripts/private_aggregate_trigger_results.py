#!/usr/bin/env python3
"""Aggregate isolated-agent trigger runs from a JSONL evidence file."""

import argparse
import json
import sys
from collections import OrderedDict
from pathlib import Path

EVIDENCE_KINDS = {"skill_load_event", "tool_log", "agent_self_report"}
REQUIRED_FIELDS = (
    "configuration",
    "query_id",
    "should_trigger",
    "triggered",
    "evidence",
)


def ratio(numerator, denominator):
    return round(numerator / denominator, 4) if denominator else None


def load_records(path):
    records = []
    errors = []
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    for line_number, line in enumerate(lines, 1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as error:
            errors.append("line " + str(line_number) + ": " + str(error))
            continue
        if not isinstance(record, dict):
            errors.append("line " + str(line_number) + ": expected an object")
            continue
        missing = [field for field in REQUIRED_FIELDS if field not in record]
        if missing:
            errors.append(
                "line " + str(line_number) + ": missing " + ", ".join(missing)
            )
            continue
        if not isinstance(record["configuration"], str) or not record["configuration"]:
            errors.append("line " + str(line_number) + ": invalid configuration")
        if not isinstance(record["query_id"], str) or not record["query_id"]:
            errors.append("line " + str(line_number) + ": invalid query_id")
        if type(record["should_trigger"]) is not bool:
            errors.append("line " + str(line_number) + ": should_trigger must be boolean")
        if type(record["triggered"]) is not bool:
            errors.append("line " + str(line_number) + ": triggered must be boolean")
        evidence = record["evidence"]
        if not isinstance(evidence, dict):
            errors.append("line " + str(line_number) + ": evidence must be an object")
        else:
            if evidence.get("kind") not in EVIDENCE_KINDS:
                errors.append("line " + str(line_number) + ": invalid evidence.kind")
            if not isinstance(evidence.get("ref"), str) or not evidence.get("ref").strip():
                errors.append("line " + str(line_number) + ": evidence.ref is required")
        records.append(record)
    if not records and not errors:
        errors.append("no result records found")
    return records, errors


def aggregate(records, threshold):
    configurations = OrderedDict()
    consistency_errors = []
    for record in records:
        configuration = configurations.setdefault(
            record["configuration"], OrderedDict()
        )
        query_id = record["query_id"]
        query = configuration.setdefault(query_id, {
            "query_id": query_id,
            "query": record.get("query"),
            "should_trigger": record["should_trigger"],
            "runs": [],
        })
        if query["should_trigger"] != record["should_trigger"]:
            consistency_errors.append(
                record["configuration"] + "/" + query_id
                + " has inconsistent should_trigger labels"
            )
        query["runs"].append(record)
    if consistency_errors:
        return None, consistency_errors

    output = []
    for configuration_name, queries in configurations.items():
        query_results = []
        true_positive = false_negative = false_positive = true_negative = 0
        strong_runs = weak_runs = 0
        for query in queries.values():
            runs = query["runs"]
            triggered_count = sum(run["triggered"] for run in runs)
            trigger_rate = triggered_count / len(runs)
            should_trigger = query["should_trigger"]
            passed = (
                trigger_rate > threshold
                if should_trigger
                else trigger_rate < threshold
            )
            for run in runs:
                if run["evidence"]["kind"] == "agent_self_report":
                    weak_runs += 1
                else:
                    strong_runs += 1
                if should_trigger and run["triggered"]:
                    true_positive += 1
                elif should_trigger:
                    false_negative += 1
                elif run["triggered"]:
                    false_positive += 1
                else:
                    true_negative += 1
            query_results.append({
                "query_id": query["query_id"],
                "query": query["query"],
                "should_trigger": should_trigger,
                "runs": len(runs),
                "triggered_runs": triggered_count,
                "trigger_rate": round(trigger_rate, 4),
                "passed": passed,
            })
        passed_queries = sum(query["passed"] for query in query_results)
        output.append({
            "configuration": configuration_name,
            "summary": {
                "queries": len(query_results),
                "runs": sum(query["runs"] for query in query_results),
                "query_pass_rate": ratio(passed_queries, len(query_results)),
                "positive_recall": ratio(
                    true_positive, true_positive + false_negative
                ),
                "false_trigger_rate": ratio(
                    false_positive, false_positive + true_negative
                ),
                "strong_evidence_runs": strong_runs,
                "weak_evidence_runs": weak_runs,
            },
            "per_query": query_results,
        })
    return output, []


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", help="JSONL file with one run per line")
    parser.add_argument(
        "--threshold", type=float, default=0.5,
        help="Positive rates must exceed and negative rates must be below this",
    )
    arguments = parser.parse_args()
    if not 0 <= arguments.threshold <= 1:
        parser.error("--threshold must be between 0 and 1")
    try:
        records, errors = load_records(arguments.results)
    except (OSError, UnicodeError) as error:
        print(str(error), file=sys.stderr)
        return 1
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    configurations, errors = aggregate(records, arguments.threshold)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(json.dumps({
        "threshold": arguments.threshold,
        "configurations": configurations,
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
