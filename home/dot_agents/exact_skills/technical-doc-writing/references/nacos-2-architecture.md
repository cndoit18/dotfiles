---
title: "支持 gRPC 长链接：Nacos 2.0 架构设计及新模型"
author: "杨翊（席翁，Nacos PMC）"
source: "https://developer.aliyun.com/article/780680"
license: "未声明（用户授权收录）"
use_for: "中文架构演进：1.X 问题、同一注册流程、新旧模型、新架构复杂度与有状态化代价"
kind: "机制/方案"
language: "zh"
read_next: "Nacos 1.X 架构及问题 → Nacos 2.0 架构及新模型（含优缺点）完整章节；忽略加入我们、活动推广和站点尾部导航"
do_not_copy: "技术事实、项目结论、性能数字、案例数据与作者口癖"
provenance_note: "作者、固定提交或发布日期见源文；网页日期不等于全文未修改证明"
changes: "增加元数据与使用说明；网页正文转为文本；Markdown 相对图片链接按需改为固定版本绝对链接"
cleanup: "从原网页重新转换，恢复 11 张正文图片；删除招聘、活动 CTA 与尾部营销；修复作者/来源链接格式"
---

![头图.jpg](https://ucc.alicdn.com/pic/developer-ecology/824bc310028840f38fff8071ed5b2515.jpg?x-oss-process=image/resize,w_1400/format,webp)

作者：杨翊（席翁，Nacos PMC）；来源：[阿里巴巴云原生公众号](https://mp.weixin.qq.com/s/nShELZj8rjeeWRh_zuSbFw)

## Nacos 简介

![1.jpeg](https://ucc.alicdn.com/pic/developer-ecology/756f15ea62c2469b9317c8f59260d3b3.jpeg?x-oss-process=image/resize,w_1400/format,webp)

Nacos 在阿里巴巴起源于 2008 年五彩石项目，该项目完成了微服务拆分和业务中台建设，随着云计算和开源环境的兴起，2018 年我们深刻感受到开源软件行业的影响，因此决定将 Nacos 开源，输出阿里十年关于服务发现和配管管理的沉淀，推动微服务行业发展，加速企业数字化转型。

目前 Nacos 支持主流微服务开发语言 & 主流服务框架和配置管理框架，比如支持 Duboo 和 SCA， 还对接了一些云原生的组件比如 coreDNS 和 sentinel 等。

客户端语言方面支持诸如 Java、go python 等主流语言，还有近期刚发布正式版本的 C# 和 C++，在此感谢所有社区贡献者的支持。

![2.jpeg](https://ucc.alicdn.com/pic/developer-ecology/ca5bd67be3844b528ac93a8c92fa70ae.jpeg?x-oss-process=image/resize,w_1400/format,webp)

Nacos 开源 2 年多以来，共发布了 34 个版本，其中有一些比较重要的里程碑版本；Nacos 还非常年轻，有很大的进步空间，欢迎社区及各界大佬一起共同建设。

![3.jpeg](https://ucc.alicdn.com/pic/developer-ecology/fcfa545bdaba4aba8f3afba5f232316f.jpeg?x-oss-process=image/resize,w_1400/format,webp)

## Nacos 1.X 架构及问题

接下来我们看一下 nacos1.x 架构及其分析一下存在的比较重要的问题。首先来看一下架构简图。

### Nacos 1.X 架构层次

![4.jpeg](https://ucc.alicdn.com/pic/developer-ecology/a40410451cf34cee8a62e9aeed187241.jpeg?x-oss-process=image/resize,w_1400/format,webp)

Nacos 1.X 大致分为 5 层， 分别是接入、通信、功能、同步和持久化。

**接入层**是用户最直接交互的层面，主要有 Nacos 客户端，以及依赖客户端的 Dubbo 和 SCA 以及用户操作的控制台 Console 组成。客户端和 Console 进行服务和配置操作，统一通过 HTTP 的 OpenAPI 发起通信请求。

**通信层**主要基于 HTTP 的短连接请求模型进行，部分推送功能通过 UDP 进行通信。

**功能**目前有服务发现和配置管理，这层也就是实际管理服务和配置的业务层。

**同步层**有数据同步的 AP 模式 Distro 和 CP 模式 Raft，还有有一个最简易的水平通知 Notify，用处各不相同：

- Distro：非持久化服务的同步模式。
- Raft：持久化服务的同步模式、以及使用 Derby 作为配置的存储时同步配置操作。
- Notify：使用 MySQL 作为配置的存储时，通知其他节点更新缓存及发起配置推送。

**持久化层** Nacos 使用 MySQL、Derby 和本地文件系统来进行数据的持久化 配置信息，用户信息，权限信息存储在 MySQL 或 Derby 数据库中， 持久化服务信息及服务和实例元数据信息存储在本地文件系统。

### Nacos 1.X 架构下的服务模型

我们通过一个服务发现的流程，再深入熟悉一下 Nacos 1.X 架构和基于当前架构的 Nacos 服务发现模型。

![5.jpeg](https://ucc.alicdn.com/pic/developer-ecology/8b00ba1492384eb3a073fc0bd61290e7.jpeg?x-oss-process=image/resize,w_1400/format,webp)

Nacos 客户端注册服务会通过 OpenAPI 发送 Http 注册服务的请求，请求内容会带上服务信息及实例信息，通常这个步骤是由微服务框架 SCA 和 dubbo 完成。

服务端收到请求后，会先在 Contoller 中进行数据的读取和校验，比如 IP 是否合法，服务名是否正确等等。校验通过后，如果这个服务是第一次注册，Nacos 会在服务端生成一个 Service 对象，然后把这次注册的实例信息存入这个 Service 对象中；如果 Nacos 服务端已经有了这个 Service 对象，那么就会直接把新注册的实例信息存入对象。这个 Service 对象通过 命名空间+Group+Service 的组合来保证唯一性。

完成实例存入 Service 的同时，会触发两个事件，其中一个事件是用于数据同步的，Nacos 服务端会根据这个服务是否是临时对象的信息，使用 Distro 或者 Raft 协议进行同步，通知其他的 Nacos 节点该服务发生了变更；另一个事件则通知在该 Nacos 服务节点上订阅了该服务的订阅者，并根据订阅者信息，通过 UDP 的方式，把最新的服务列表推送到订阅者客户端上。这就完成了一次服务注册流程。

另外，对于那些被定义为持久化的服务的所有信息，都会通过 raft 协议，保证能够写入到文件系统中被持久化。

最后，其他的 Nacos 节点，在通过同步而进行 Service 变更的时候也会触发通知订阅者的事件，从而使在其他 Nacos 服务节点上订阅该服务的订阅者也能收到推送。

### 1.X 架构存在的问题

粗略介绍了下 Nacos1.X 的架构和服务发现模型，接下来分析一下 Nacos1.X 架构所面临的几个比较重要的问题。

一句话总结，心跳多，无效查询多，心跳续约感知变化慢，连接消耗大，资源空耗严重。

![6.jpeg](https://ucc.alicdn.com/pic/developer-ecology/f0d31c18afa54f4bb5460d4516087cab.jpeg?x-oss-process=image/resize,w_1400/format,webp)

- **心跳数量多，导致 TPS 居高不下**

> 通过心跳续约，当服务规模上升时，特别是类似 Dubbo 的接口级服务较多时，心跳及配置元数据的轮询数量众多，导致集群 TPS 很高，系统资源高度空耗。

- **通过心跳续约感知服务变化，时延长**

> 心跳续约需要达到超时时间才会移除并通知订阅者，默认为 15s，时延较长，时效性差。若改短超时时间，当网络抖动时，会频繁触发变更推送，对客户端服务端都有更大损耗。

- **UDP 推送不可靠，导致 QPS 居高不下**

> 由于 UDP 不可靠，因此客户端测需要每隔一段时间进行对账查询，保证客户端缓存的服务列表的状态正确，当订阅客户端规模上升时，集群 QPS 很高，但大多数服务列表其实不会频繁改变，造成无效查询，从而存在资源空耗。

- **基于 HTTP 短连接模型，TIME_WAIT 状态连接过多**

> HTTP 短连接模型，每次客户端请求都会创建和销毁 TCP 链接，TCP 协议销毁的链接状态是 WAIT_TIME，完全释放还需要一定时间，当 TPS 和 QPS 较高时，服务端和客户端可能有大量的 WAIT_TIME 状态链接，从而会导致 connect time out 错误或者 Cannot assign requested address 的问题。

- **配置模块的 30 秒长轮询引起的频繁 GC**

> 配置模块使用 HTTP 短连接阻塞模型来模拟长连接通信，但是由于并非真实的长连接模型，因此每 30 秒需要进行一次请求和数据的上下文切换，每一次切换都有引起造成一次内存浪费，从而导致服务端频繁 GC。

## Nacos 2.0 架构及新模型

### Nacos 2.0 架构层次

Nacos 2.X 在 1.X 的架构基础上 新增了对长连接模型的支持，同时保留对旧客户端和 openAPI 的核心功能支持。

![7.jpeg](https://ucc.alicdn.com/pic/developer-ecology/8e4ccf764e4843789571322bbef06eb9.jpeg?x-oss-process=image/resize,w_1400/format,webp)

通信层目前通过 gRPC 和 Rsocket 实现了长连接 RPC 调用和推送能力。

在服务端测，新增一个链接层，用来将不同类型的 Request 请求，将来自不同客户端的不同类型请求，转化为相同语意的功能数据结构，复用业务处理逻辑。同时，将来的流量控制和负载均衡等功能也会在链接层处理。

其他架构分层在大体上保持不变。

### Nacos 2.0 新服务模型

虽然 Nacos2.0 的在架构层次上并未做太大的变化，但是具体的模型细节却有不小的改动，依旧使用注册服务的流程，再深入了解一下 Nacos2.0 服务模型的变化。

![8.jpeg](https://ucc.alicdn.com/pic/developer-ecology/6cddc5b6a17b43cd8a04c377a651b14e.jpeg?x-oss-process=image/resize,w_1400/format,webp)

由于通信使用了 RPC 方式，因此某一客户端的所有请求（无论是注册还是订阅）都通过同一个链接和同一个服务节点进行，不像之前通过 HTTP 连接可能每次请求都请求在不同的 Nacos 节点上，这就导致了服务发现的数据内容由原来的无状态化变为了与连接状态绑定的一种有状态数据。为了适应这种变化，需要改变一下数据模型，因此抽象了一个新数据结构，将同一个客户端通过该链接发布和订阅的内容关联起来，暂命名为 Client。这个 Client 不是客户端的意思，而是这个客户端所相关的数据内容，一个链接与一个 Client 对应。

当客户端发布了服务时，该客户端所发布的所有服务与订阅者信息会被更新到与该客户端链接相对应的 Client 对象中，然后通过事件机制触发对索引信息的更新。这个索引信息是客户端链接和服务的索引，方便快速聚合生成需要推送的服务纬度的数据。

索引信息更新完成后，会触发推送事件，此时会将所有和该服务有关的 Client 对象，通过刚产生的索引信息聚合起来，当数据聚合完成后，再从客户端链接中筛选出订阅该服务的订阅者的客户端链接，将推送数据通过该链接，推送回去。这样一次发布变更的主链路就完成了。

回过头看数据同步，客户端发布了服务时实际更新的对象从原来的 Service 变成 Client 对象，所以需要同步的内容也变成了 Client 对象；同时服务端间的通信方式也会换成 RPC。这里只有真正被客户端更新的 Client 对象会触发同步，如果是通过同步而更新的 Client 对象不会再次触发同步。

最后看 Metadata，Metadata 是从 1.X 版本中的 Service 对象和 Instance 对象中分离出来的一些属性：比如服务的元数据 label 标签，实例的上下线状态、权重和元数据 label 标签等。这些元数据可以被 openAPI 单独修改，在聚合数据时生效。之所以将元数据拆分出来，区别于基础数据，原因是基础数据比如：ip 端口，服务名等一经发布不应该被修改，而且应当以发布时的信息为准；但其他的原数据，比如上下线状态和权重，通常是在运行过程中动态调节的，因此拆分开之后，分为两条不同的处理工作流应该更加合理。

### Nacos 2.0 架构的优缺点

前面简要介绍了 Nacos 2.0 的架构和新模型的工作方式，接下来我们分析一下这样的改动有哪些优缺点。

![9.jpeg](https://ucc.alicdn.com/pic/developer-ecology/c97a6582f9204b6fbf90ca8f0741110b.jpeg?x-oss-process=image/resize,w_1400/format,webp)

### 优点

- 客户端不再需要定时发送实例心跳，只需要有一个维持连接可用 keepalive 消息即可。重复 TPS 可以大幅降低。
- TCP 连接断开可以被快速感知到，提升反应速度。
- 长连接的流式推送，比 UDP 更加可靠；nio 的机制具有更高的吞吐量，而且由于可靠推送，可以加长客户端用于对账服务列表的时间，甚至删除相关的请求。重复的无效 QPS 可以大幅降低。
- 长连接避免频繁连接开销，可以大幅缓解 TIME_ WAIT 问题。
- 真实的长连接，解决配置模块 GC 问题。
- 更细粒度的同步内容，减少服务节点间的通信压力。

### 缺点

没有银弹的方案，新架构也会引入一些新问题：

- 内部结构复杂度上升，管理连接状态，连接的负载均衡需要管理。
- 数据又原来的无状态，变为与连接绑定的有状态数据，流程链路更长。
- RPC 协议的观测性不如 HTTP。即使 gRPC 基于 HTTP2.0Stream 实现，仍然不如直接使用 HTTP 协议来的直观。

## Nacos 2.X 规划

接下来简单分享下 Nacos 2.X 的后期规划，主要分为文档、质量和 Roadmap。

在文档和质量方面，Nacos 1.X 都做的不是很好。文档内容较少，仅有简单使用文档；和版本有一定脱节，更新不及时；没有对技术内容的说明，参与贡献难度高。代码质量及测试质量也不是很高，虽然已经使用 checkstyle 进行了 codeStyle 的校验以及开启了社区协作 review。但是这还远远不够。Nacos 2.X 将会逐步更新、细化官网使用文档；通过电子书对技术细节进行解析；通过 Github 展示技术方案，促进讨论及贡献；并且对代码进行大量重构及 UT 和 IT 的治理工作，在未来将 Benchmark 也会开源出来，方便给开源用户进行压测。

![10.jpeg](https://ucc.alicdn.com/pic/developer-ecology/ed86c2eec109466b8be8078e87a4bb82.jpeg?x-oss-process=image/resize,w_1400/format,webp)

而 RoadMap 方面，Nacos 2.X 会对项目做大幅度的重构，完成初步插件化，并对刚才 2.0 架构的一些缺点，如负载均衡，可观测性进行提升。

## 加入我们

欢迎在 [Nacos github](https://github.com/alibaba/nacos) 上提交 issue 与 PR 进行讨论和贡献，或加入 Nacos 社区群参与社区讨论。

本文整理自 [Spring Cloud Alibaba Meetup 杭州站演讲](http://mp.weixin.qq.com/s?__biz=MzUzNzYxNjAzMg==&mid=2247497135&idx=1&sn=af97baa4570bd21cf3eb81ca82a51978&chksm=fae6fe60cd9177762fda42c65d49118303b18933d33a33531938189d26def74c36d9f2167bef&scene=21#wechat_redirect)

### **作者简介**

杨翊，花名席翁。Nacos PMC，主要参与的是服务发现模块，和做一些内核重构和提升的工作。Apache SharadingSphere PMC，主要负责和参与过的模块有 路由模块、分布式事务、 数据同步、以及弹性扩容。
