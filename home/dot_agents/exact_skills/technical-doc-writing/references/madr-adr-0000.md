---
title: "Use Markdown Architectural Decision Records"
author: "MADR contributors"
source: "https://github.com/adr/madr/blob/4f2f073193ffcce3bdcdeac13dccf53494ab442d/template/0000-use-markdown-architectural-decision-records.md"
version: "4f2f073193ffcce3bdcdeac13dccf53494ab442d (2020-10-03)"
license: "CC0 1.0"
license_url: "https://creativecommons.org/publicdomain/zero/1.0/"
use_for: "短决策记录：问题、候选方案、选择结果与理由"
kind: "决策记录"
language: "en"
read_next: "短篇，整篇；不得因模仿而省略当前必需的代价或验证"
do_not_copy: "MADR 的选型结论和候选方案"
changes: "仅增加元数据与使用说明，原文未改"
---

# 真人范文：短架构决策记录

> 学习如何用少量文字交代问题和选择理由；不要为了模仿此样本而省略当前决策必需的代价、风险或验证。

---

# Use Markdown Architectural Decision Records

## Context and Problem Statement

We want to record architectural decisions made in this project.
Which format and structure should these records follow?

## Considered Options

* [MADR](https://adr.github.io/madr/) 2.1.2 – The Markdown Architectural Decision Records
* [Michael Nygard's template](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions) – The first incarnation of the term "ADR"
* [Sustainable Architectural Decisions](https://www.infoq.com/articles/sustainable-architectural-design-decisions) – The Y-Statements
* Other templates listed at <https://github.com/joelparkerhenderson/architecture_decision_record>
* Formless – No conventions for file format and structure

## Decision Outcome

Chosen option: "MADR 2.1.2", because

* Implicit assumptions should be made explicit.
  Design documentation is important to enable people understanding the decisions later on.
  See also [A rational design process: How and why to fake it](https://doi.org/10.1109/TSE.1986.6312940).
* The MADR format is lean and fits our development style.
* The MADR structure is comprehensible and facilitates usage & maintenance.
* The MADR project is vivid.
* Version 2.1.2 is the latest one available when starting to document ADRs.

<!-- markdownlint-disable-file MD013 -->
