---
title: "Berkeley DB"
author: "Margo Seltzer and Keith Bostic"
source: "https://github.com/aosabook/aosabook/blob/4dbfc9eec4522c4d4ebfd6f5729b01eb9313032b/v1/web/en/bdb.html"
version: "4dbfc9eec4522c4d4ebfd6f5729b01eb9313032b (2013-11-03; source provenance 2011-05-25)"
license: "CC BY 3.0"
license_url: "https://creativecommons.org/licenses/by/3.0/"
use_for: "架构叙述：问题历史、整体结构、设计经验"
kind: "设计论证"
language: "en"
read_next: "已是节选，整篇；英文只学结构，不学中文翻译腔"
do_not_copy: "Berkeley DB 的技术事实、历史结论和特定作者口癖"
changes: "仅选 4.1、4.2、4.10；HTML 转为 Markdown，保留图，省略 API 对照表，未改段落措辞"
---

# 真人范文：Berkeley DB（节选）

> 仅学习如何从历史问题进入整体架构，以及如何用设计经验收束正文。英文样本只学结构，不模仿中文翻译腔。省略内容已明确标注，完整书稿见固定版本源文。

---

## 4.1. In the Beginning

Berkeley DB dates back to an era when the Unix operating system was proprietary to AT&T and there were hundreds of utilities and libraries whose lineage had strict licensing constraints. Margo Seltzer was a graduate student at the University of California, Berkeley, and Keith Bostic was a member of Berkeley's Computer Systems Research Group. At the time, Keith was working on removing AT&T's proprietary software from the Berkeley Software Distribution.

The Berkeley DB project began with the modest goal of replacing the in-memory `hsearch` hash package and the on-disk `dbm/ndbm` hash packages with a new and improved hash implementation able to operate both in-memory and on disk, as well as be freely redistributed without a proprietary license. The `hash` library that Margo Seltzer wrote [[SY91](https://aosabook.org/en/v1/bibliography.html#bib:seltzer:hash)] was based on Litwin's Extensible Linear Hashing research. It boasted a clever scheme allowing a constant time mapping between hash values and page addresses, as well as the ability to handle large data—items larger than the underlying hash bucket or filesystem page size, typically four to eight kilobytes.

If hash tables were good, then Btrees and hash tables would be better. Mike Olson, also a graduate student at the University of California, Berkeley, had written a number of Btree implementations, and agreed to write one more. The three of us transformed Margo's hash software and Mike's Btree software into an access-method-agnostic API, where applications reference hash tables or Btrees via database handles that had handle methods to read and modify data.

Building on these two access methods, Mike Olson and Margo Seltzer wrote a research paper ([[SO92](https://aosabook.org/en/v1/bibliography.html#bib:seltzer:libtp)]) describing LIBTP, a programmatic transactional library that ran in an application's address space.

The hash and Btree libraries were incorporated into the final 4BSD releases, under the name Berkeley DB 1.85. Technically, the Btree access method implements a B+link tree, however, we will use the term Btree for the rest of this chapter, as that is what the access method is called. Berkeley DB 1.85's structure and APIs will likely be familiar to anyone who has used any Linux or BSD-based system.

The Berkeley DB 1.85 library was quiescent for a few years, until 1996 when Netscape contracted with Margo Seltzer and Keith Bostic to build out the full transactional design described in the LIBTP paper and create a production-quality version of the software. This effort produced the first transactional version of Berkeley DB, version 2.0.

The subsequent history of Berkeley DB is a simpler and more traditional timeline: Berkeley DB 2.0 (1997) introduced transactions to Berkeley DB; Berkeley DB 3.0 (1999) was a re-designed version, adding further levels of abstraction and indirection to accommodate growing functionality. Berkeley DB 4.0 (2001) introduced replication and high availability, and Oracle Berkeley DB 5.0 (2010) added SQL support.

At the time of writing, Berkeley DB is the most widely used database toolkit in the world, with hundreds of millions of deployed copies running in everything from routers and browsers to mailers and operating systems. Although more than twenty years old, the Berkeley DB tool-based and object-oriented approach has allowed it to incrementally improve and re-invent itself to match the requirements of the software using it.

> **Design Lesson 1**

> It is vital for any complex software package's testing and maintenance that the software be designed and built as a cooperating set of modules with well-defined API boundaries. The boundaries can (and should!) shift as needs dictate, but they always need to be there. The existence of those boundaries prevents the software from becoming an unmaintainable pile of spaghetti. Butler Lampson once said that all problems in computer science can be solved by another level of indirection. More to the point, when asked what it meant for something to be object-oriented, Lampson said it meant being able to have multiple implementations behind an API. The Berkeley DB design and implementation embody this approach of permitting multiple implementations behind a common interface, providing an object-oriented look and feel, even though the library is written in C.

---

## 4.2. Architectural Overview

In this section, we'll review the Berkeley DB library's architecture, beginning with LIBTP, and highlight key aspects of its evolution.

[Figure 4.1](https://aosabook.org/en/v1/bdb.html#fig.bdb.libtp), which is taken from Seltzer and Olson's original paper, illustrates the original LIBTP architecture, while [Figure 4.2](https://aosabook.org/en/v1/bdb.html#fig.bdb.bdb20) presents the Berkeley DB 2.0 designed architecture.

![Architecture of the LIBTP Prototype System](https://aosabook.org/en/images/bdb/libtp.png)

*Figure 4.1: Architecture of the LIBTP Prototype System*

![Intended Architecture for Berkeley DB-2.0.](https://aosabook.org/en/images/bdb/bdb20.png)

*Figure 4.2: Intended Architecture for Berkeley DB-2.0.*

The only significant difference between the LIBTP implementation and the Berkeley DB 2.0 design was the removal of the process manager. LIBTP required that each thread of control register itself with the library and then synchronized the individual threads/processes rather than providing subsystem level synchronization. As is discussed in [Section 4.4](https://aosabook.org/en/v1/bdb.html#sec.bdb.int), that original design might have served us better.

![Actual Berkeley DB 2.0.6 Architecture.](https://aosabook.org/en/images/bdb/bdb20-actual.png)

*Figure 4.3: Actual Berkeley DB 2.0.6 Architecture.*

The difference between the design and the actual released db-2.0.6 architecture, shown in [Figure 4.3](https://aosabook.org/en/v1/bdb.html#fig.bdb.bdbact), illustrates the reality of implementing a robust recovery manager. The recovery subsystem is shown in gray. Recovery includes both the driver infrastructure, depicted in the recovery box, as well as a set of recovery redo and undo routines that recover the operations performed by the access methods. These are represented by the circle labelled "access method recovery routines." There is a consistent design to how recovery is handled in Berkeley DB 2.0 as opposed to hand-coded logging and recovery routines in LIBTP particular to specific access methods. This general purpose design also produces a much richer interface between the various modules.

[Figure 4.4](https://aosabook.org/en/v1/bdb.html#fig.bdb.bdb50) illustrates the Berkeley DB-5.0.21 architecture. The numbers in the diagram reference the APIs listed in the table in [Table 4.1](https://aosabook.org/en/v1/bdb.html#tbl.bdb.apitab). Although the original architecture is still visible, the current architecture shows its age with the addition of new modules, the decomposition of old modules (e.g., `log` has become `log` and `dbreg`), and a significant increase in the number of intermodule APIs).

Over a decade of evolution, dozens of commercial releases, and hundreds of new features later, we see that the architecture is significantly more complex than its ancestors. The key things to note are: First, replication adds an entirely new layer to the system, but it does so cleanly, interacting with the rest of the system via the same APIs as does the historical code. Second, the `log` module is split into `log` and `dbreg` (database registration). This is discussed in more detail in [Section 4.8](https://aosabook.org/en/v1/bdb.html#sec.bdb.log). Third, we have placed all inter-module calls into a namespace identified with leading underscores, so that applications won't collide with our function names. We discuss this further in Design Lesson 6.

Fourth, the logging subsystem's API is now cursor based (there is no `log_get` API; it is replaced by the `log_cursor` API). Historically, Berkeley DB never had more than one thread of control reading or writing the log at any instant in time, so the library had a single notion of the current seek pointer in the log. This was never a good abstraction, but with replication it became unworkable. Just as the application API supports iteration using cursors, the log now supports iteration using cursors. Fifth, the `fileop` module inside of the access methods provides support for transactionally protected database create, delete, and rename operations. It took us multiple attempts to make the implementation palatable (it is still not as clean as we would like), and after reworking it numerous time, we pulled it out into its own module.

> **Design Lesson 2**

> A software design is simply one of several ways to force yourself to think through the entire problem before attempting to solve it. Skilled programmers use different techniques to this end: some write a first version and throw it away, some write extensive manual pages or design documents, others fill out a code template where every requirement is identified and assigned to a specific function or comment. For example, in Berkeley DB, we created a complete set of Unix-style manual pages for the access methods and underlying components before writing any code. Regardless of the technique used, it's difficult to think clearly about program architecture after code debugging begins, not to mention that large architectural changes often waste previous debugging effort. Software architecture requires a different mind set from debugging code, and the architecture you have when you begin debugging is usually the architecture you'll deliver in that release.

![Berkeley DB-5.0.21 Architecture](https://aosabook.org/en/images/bdb/bdb50.png)

*Figure 4.4: Berkeley DB-5.0.21 Architecture*

> [Editorial omission: Table 4.1: Berkeley DB 5.0.21 APIs; see the source document.]

Why architect the transactional library out of components rather than tune it to a single anticipated use? There are three answers to this question. First, it forces a more disciplined design. Second, without strong boundaries in the code, complex software packages inevitably degenerate into unmaintainable piles of glop. Third, you can never anticipate all the ways customers will use your software; if you empower users by giving them access to software components, they will use them in ways you never considered.

In subsequent sections we'll consider each component of Berkeley DB, understand what it does and how it fits into the larger picture.

---

## 4.10. Wrapping Up

Berkeley DB is now over twenty years old. It was arguably the first general-purpose transactional key/value store and is the grandfather of the NoSQL movement. Berkeley DB continues as the underlying storage system for hundreds of commercial products and thousands of Open Source applications (including SQL, XML and NoSQL engines) and has millions of deployments across the globe. The lessons we've learned over the course of its development and maintenance are encapsulated in the code and summarized in the design tips outlined above. We offer them in the hope that other software designers and architects will find them useful.
