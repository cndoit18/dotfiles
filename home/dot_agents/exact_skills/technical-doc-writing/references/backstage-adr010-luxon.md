---
title: "Backstage ADR010：Use the Luxon Date Library"
author: "Andrew Thauer / Backstage"
source: "https://github.com/backstage/backstage/blob/54dd7b300367684756eb86bb42a315a070ea419f/docs/architecture-decisions/adr010-luxon-date-library.md"
license: "Apache-2.0"
use_for: "短决策：真实场景、包体积与可变性、统一依赖、学习与迁移后果"
kind: "决策记录"
language: "en"
read_next: "短篇，整篇；备选比较较薄，需比较时补读其他 ADR"
do_not_copy: "技术事实、项目结论、性能数字、案例数据与作者口癖"
provenance_note: "作者与固定提交见源文；固定提交保证文本可复现"
changes: "增加元数据与使用说明；按需合并原 front matter，并将相对图片链接改为固定版本绝对链接"
---

> 仅学习上述指定类型的信息组织与表达，不把范文事实作为当前文档依据。完整来源、作者和许可状态见上方元数据。

---

id: adrs-adr010
title: ADR010: Use the Luxon Date Library
description: Architecture Decision Record (ADR) for Luxon Date Library

# ADR010: Use the Luxon Date Library

## Context

Date formatting (e.g. `a day ago`) and calculations are common within Backstage.
Some of these useful features are not supported by the standard JavaScript
`Date` object. The popular [Moment.js](https://momentjs.com/) library has been
commonly used to fill this gap but suffers from large bundle sizes and mutable
state issues. On top of this, `momentjs` is
[being sunset](https://momentjs.com/docs/#/-project-status/) and the project
recommends using one of the more modern alternative libraries.

See
[[RFC] Standardized Date & Time Library](https://github.com/backstage/backstage/issues/3401).

## Decision

We will use [Luxon](https://moment.github.io/luxon/index.html) as the standard
date library within Backstage.

`Luxon` provides a similar feature set and API to `Moment.js`, but improves on
its design through immutability and the usage of modern JavaScript APIs (e.g.
`Intl`). This results in smaller bundle sizes while providing a full feature set
and avoids the need for using additional libraries for common date & time tasks.

## Consequences

- All core packages and plugins within Backstage should use `Luxon` for any date
  manipulation or formatting that cannot be easily accomplished with the native
  JavaScript `Date` object.
- Using a single date library avoids having to learn multiple library APIs
- Having a single date library will reduce bundle sizes
