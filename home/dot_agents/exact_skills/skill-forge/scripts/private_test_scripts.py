#!/usr/bin/env python3
"""Regression tests for skill-forge's standard-library scripts."""

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SKILL_ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = SKILL_ROOT / "scripts" / "validate_skill.py"
AGGREGATOR = SKILL_ROOT / "scripts" / "aggregate_trigger_results.py"


class ScriptTests(unittest.TestCase):
    def run_script(self, script, *arguments):
        return subprocess.run(
            [sys.executable, str(script), *map(str, arguments)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_validator_accepts_block_description_and_existing_reference(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "sample-skill"
            (root / "references").mkdir(parents=True)
            (root / "references" / "guide.md").write_text("# Guide\n", encoding="utf-8")
            (root / "SKILL.md").write_text(
                "---\n"
                "name: sample-skill\n"
                "description: >\n"
                "  Analyze tabular files and generate charts.\n"
                "  Use when cleaning or visualizing local CSV data.\n"
                "---\n"
                "# Sample\n"
                "See [the guide](references/guide.md).\n",
                encoding="utf-8",
            )
            completed = self.run_script(VALIDATOR, root)
            self.assertEqual(completed.returncode, 0, completed.stderr)
            self.assertTrue(json.loads(completed.stdout)["valid"])

    def test_validator_rejects_name_mismatch_and_missing_reference(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "sample-skill"
            root.mkdir()
            (root / "SKILL.md").write_text(
                "---\n"
                "name: different-name\n"
                "description: Analyze local CSV files.\n"
                "---\n"
                "See [missing](references/missing.md).\n",
                encoding="utf-8",
            )
            completed = self.run_script(VALIDATOR, root)
            self.assertEqual(completed.returncode, 1)
            errors = json.loads(completed.stdout)["errors"]
            self.assertTrue(any("parent directory" in error for error in errors))
            self.assertTrue(any("missing" in error for error in errors))

    def test_aggregator_computes_rates_and_counts_weak_evidence(self):
        records = []
        for index, triggered in enumerate((True, True, False)):
            kind = "agent_self_report" if index == 2 else "skill_load_event"
            records.append({
                "configuration": "candidate",
                "query_id": "positive",
                "should_trigger": True,
                "triggered": triggered,
                "evidence": {"kind": kind, "ref": "run-positive-" + str(index)},
            })
        for index, triggered in enumerate((False, False, True)):
            records.append({
                "configuration": "candidate",
                "query_id": "negative",
                "should_trigger": False,
                "triggered": triggered,
                "evidence": {"kind": "tool_log", "ref": "run-negative-" + str(index)},
            })
        with tempfile.TemporaryDirectory() as temporary:
            result_file = Path(temporary) / "results.jsonl"
            result_file.write_text(
                "\n".join(json.dumps(record) for record in records) + "\n",
                encoding="utf-8",
            )
            completed = self.run_script(AGGREGATOR, result_file)
            self.assertEqual(completed.returncode, 0, completed.stderr)
            report = json.loads(completed.stdout)["configurations"][0]
            self.assertEqual(report["summary"]["query_pass_rate"], 1.0)
            self.assertEqual(report["summary"]["positive_recall"], 0.6667)
            self.assertEqual(report["summary"]["false_trigger_rate"], 0.3333)
            self.assertEqual(report["summary"]["strong_evidence_runs"], 5)
            self.assertEqual(report["summary"]["weak_evidence_runs"], 1)

    def test_aggregator_rejects_missing_evidence_reference(self):
        record = {
            "configuration": "candidate",
            "query_id": "positive",
            "should_trigger": True,
            "triggered": True,
            "evidence": {"kind": "tool_log", "ref": ""},
        }
        with tempfile.TemporaryDirectory() as temporary:
            result_file = Path(temporary) / "results.jsonl"
            result_file.write_text(json.dumps(record) + "\n", encoding="utf-8")
            completed = self.run_script(AGGREGATOR, result_file)
            self.assertEqual(completed.returncode, 1)
            self.assertIn("evidence.ref", completed.stderr)


if __name__ == "__main__":
    unittest.main()
