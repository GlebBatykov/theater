<div align="center" width="200px">

<img src="https://github.com/GlebBatykov/theater/blob/dev/logo.png?raw=true" width="700px"/>

Actor framework for Dart
  
</div>

<div align="center">

[![pub package](https://img.shields.io/pub/v/theater.svg?label=theater&color=blue)](https://pub.dev/packages/theater)

**Languages:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](README.ru.md)
  
</div>  

- [Introduction](#introduction)
- [About Theater](#about-theater)
- [Installing](#installing)
- [What is Actor](#what-is-actor)
  - [Notes about the actors](#notes-about-the-actors)
  - [Using Actors](#using-actors)
- [Actor system](#actor-system)
  - [Actor tree](#actor-tree)
- [Actor types](#actor-types)
- [Routing](#routing)
  - [Mailboxes](#mailboxes)
    - [Unreliable mailbox](#unreliable-mailbox)
    - [Reliable mailbox](#reliable-mailbox)
    - [Priority mailbox](#priority-mailbox)
  - [Sending messages](#sending-messages)
    - [Send by link](#send-by-link)
    - [Getting link](#getting-link)
    - [Send without link](#send-without-link)
    - [Receiving messages](#receiving-messages)
    - [Get message response](#get-message-response)
    - [Listening messages by the actor system](#listening-messages-by-the-actor-system)
    - [Message sending rate](#message-sending-rate)
  - [Routers](#routers)
    - [Group router](#group-router)
    - [Pool router](#pool-router)
- [Transfer data to actor](#transfer-data-to-actor)
- [Supervising and error handling](#supervising-and-error-handling)
- [Remoting [Beta]](#remoting-beta)
  - [Setup actor system](#setup-actor-system)
    - [Serialization](#serialization)
  - [Getting remote link](#getting-remote-link)
  - [Example](#example)
  - [Network security](#network-security)
  - [Protocol TCP](#protocol-tcp)
- [Utilities](#utilities)
  - [Scheduler](#scheduler)
    - [Repeatedly action](#repeatedly-action)
    - [Stop and resume repeatedly action](#stop-and-resume-repeatedly-action)
    - [One shot action](#one-shot-action)

# Introduction

I asked myself the question - "How can I write multithreaded programs on Dart?".

Dart has a built-in mechanism that allows you to implement multithreaded code execution - isolates.

By themselves, isolates in Dart are a variation of the implementation of the actor model (using separate memory, communicating by sending messages), but they do not have tools for simply creating a set of isolates communicating with each other (it is necessary to constantly transfer the Send ports of some isolates to others to enable communication between them), error handling scenarios, load balancers.

When creating this package, I was inspired by Akka net and other frameworks with an implemented actor model. But I did not set a goal to transfer Akka net to Dart, but only took some moments that I liked in it and remade it for myself.

At the moment, the package is under development, I will be very glad to hear anyone's comments, ideas or messages about the problems found.

# About Theater

Theater is a package to simplify working with multithreading in Dart, to simplify working with isolates.

It provides:

- a system for routing messages between actors (isolates), which encapsulates work with Receive and Send ports;
- error handling system at the level of one actor or a group of actors;
- the ability to configure message routing (special actors - routers that allow you to set one of the proposed message routing strategy between their child actors, the ability to set priority to messages of a certain type);
- ability to load balance (messages) between actors, creating pools of actors;
- the ability to schedule tasks performed periodically after a time, cancel them and resume;
- possibility of remote interaction between actor systems.

# Installing

Add Theater to your pubspec.yaml file:

```dart
dependencies:
  theater: ^0.2.2
```

Import theater in files that it will be used:

```dart
import 'package:theater/theater.dart';
```

# What is Actor

An actor is an entity that has a behavior and is executed in a separate isolate. It has its own unique address (path) in the actor system. He can receive and send messages to other actors using links to them or using only their address (path) in the actor system. Each actor has methods called during its lifecycle (which repeat the lifecycle of its isolate):

- onStart(). Called after the actor starts;
- onPause(). Called before the actor is paused;
- onResume(). Called after the actor is resumed;
- onKill(). Called before the actor is killed.

Each actor has a mailbox. This is the place where the messages addressed to him get to before getting into the actor. About the types of mailboxes, you can read [here](#mailboxes).

Actors can create child actors. And act as their supervisors (monitor their life cycle, handle errors that occur in them). The life cycle of child actors also depends on the life cycle of their parents.

## Notes about the actors

When an actor is paused, all his child actors are paused first.

Example: there are 3 actors A1, A2, A3. A1 created A2, A2 created A3. If A1 pauses A2, A3 will also be paused. In this case, A3 will be paused first, and then A2.

When an actor is killed, all of his children are killed first.

Example: there are 3 actors A1, A2, A3. A1 created A2, A2 created A3. If A1 destroys A2, A3 will also be killed. In this case, A3 will be killed first, and then A2.

## Using Actors

You can understand how actors work by reading this README and looking at examples in the README or [here](https://github.com/GlebBatykov/theater/blob/main/example/README.md).

However, I think it's worth mentioning how I suggest using actors in Dart programs.

One actor must encapsulate one specific task in itself, if the task can be divided into subtasks, then in this case, child actors should be created for the actor who implements the large task and repeat this until one actor has performed any one specific task.

It should be borne in mind that the use of actors (isolates) is not appropriate for all tasks. Forwarding messages between isolates takes some time and should be used only when the performance gain from parallel computing will outweigh the time wasted in sending the message.

First of all, this approach would allow more efficient use of Dart on the server (more easily and quickly implementing multithreaded request processing, building more complex interaction schemes between isolates), but this package can be used in Flutter applications as well.

# Actor system

A actor system is a group of actors in a hierarchical structure in the form of a tree. In the package, the actor system is represented by the class ActorSystem. Before working with it (creating actors, sending messages, etc.), you need to initialize it. During initialization, the actor system will create the system actors that are required for its operation.

Actors created during the initialization of the actor system:

- Root actor. A unique actor created by the actor system upon initialization. It is unique in that it does not have a parent in the form of another actor, its parent and the one who controls its life cycle is the actor system. At startup, it creates two actors, a system guardian and a user guardian;
- System guardian. The actor who is the progenitor of all system actors;
- User guardian. Actor that is the parent of all top-level actors created by the user.

Create and initialize an actor system, create a test actor, and output "Hello, world!" out of him:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Print 'Hello, world!'
    print('Hello, world!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

The created test actor in the example above will have an absolute path to it in the actor system - "test_system/root/user/test_actor".

The ActorSystem has methods that pause, resume, and kill all actors.

The dispose ActorSystem method kills all actors, as well as closes all Streams and releases all resources used by the actor system. After calling the dispose method, further use of the same ActorSystem instance is impossible.

If you called the kill method after killing all the actors in the actor system, then to continue working with the same ActorSystem instance, you must call its initialize method again. However, in this case, all top-level actors will have to be recreated.

## Actor tree

In Theater, the actor system is represented as a hierarchical structure of actors, this structure is called the actor tree.

This is how the tree of actors can be shown at the picture below:

<div align = "center">

![](https://i.ibb.co/qC98V4j/Actor-tree.png)
  
</div>
  
Actors in the tree are divided into 2 categories:

- supervisor. Supervisor are those actors who can create their own child actors (and themselves, in turn, have a supervisor actor);
- observable. Observable actors are actors that cannot create child actors.

Supervisors control the life cycle of their child actors (start, kill, stop, resume, restart), they receive messages about errors occurring in the child actors and make decisions in accordance with the established strategy (SupervisorStrategy). You can read more about error handling in child actors [here](#supervising-and-error-handling).

If we transfer these 2 categories to concepts closer to the structure of the tree, these categories can be called as follows:

- supervisor actor is a node of the tree;
- observed actor is a sheet of the tree.

A special case of an actor-node is a root actor. This is an actor who has child actors, but at the same time does not have an supervisor in the form of another actor. Its supervisor is the actor system itself.
  
# Actor types

In the Theater, the following actors are presented to the user for use:

- Untyped actor. A universal actor with no special purpose. Can receive and send messages to other actors. Can create child actors;
- Routers. Actors are routers that route incoming requests between them children actors in accordance with the established routing strategy;
  - Pool Router Actor. Actor is a router, at startup a pool of the same type of WorkerActors. You cannot directly send messages its Worker pool, all requests to the pool come only through it. It can send messages to other actors, all messages are received and routed to its own actor pool;
  - Group Router Actor. Actor is a router. Can send messages to other actors, but all messages that it receives are routed to their children. It differs from PoolRouterActor in that a messages can be sent to its him children group directly, and not only through it;
- Working actor. A worker actor uses PoolRouterActor in the pool of actors, similar to UntypedActor, but it cannot create child actors and has some internal differences in work.

# Routing

## Actor address

The routing of messages in the Theater is inextricably linked with the concept of an actor's address, a path to him. It should be clarified that the actor's address is unique, that is, there cannot be two actors with the same addresses.

The absolute path to the actor is given from the name of the actor system. The path to the actor also includes the names of the actor system, if we are talking about an actor created by the user, the root actor and user guardian (user) are indicated.

An example of displaying the absolute path to the created top-level actor:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    print(context.path);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

Expected output:

```dart
test_system/root/user/test_actor
```

## Mailboxes

Each actor has a mailbox in the Theater. The mailbox is the place where requests addressed to the actor go.

Mailboxes are divided into 2 types:

- unreliable;
- reliable.

### Unreliable mailbox

Unreliable mailboxes are mailboxes without proof of delivery. Each actor has an untrusted mailbox by default.

### Reliable mailbox

A reliable mailbox is a delivery confirmation mailbox.

Confirmation of delivery means that the mailbox, after sending a message to the actor, waits for the message from the actor with confirmation of the fact that the message has been delivered to it. Only after receiving the confirmation does the mailbox send the next message to the actor.

By receiving a message by an actor, we mean exactly the fact that a message has been received and the assigned handlers for this message have been launched, but not the fact that all the handlers assigned to it have been executed.

This degrades performance for an increase in the amount of traffic, but provides some additional guarantees that the actor will receive the messages sent to him. Due to the increase in traffic and the waste of time on sending additional messages, waiting for their receipt, the speed of sending messages deteriorates by more than 2 times.

In what situations can an actor not receive messages sent to him?

If the actor was killed in the process of work, he will not process the messages sent to him until it is launched again and these messages will be in his mailbox at that time.

However, in addition to this, there are other internal means at the level of each actor, which, in the event of an actor's destruction, allow not to lose the messages sent to him (they wait until the actor is started again), using a mailbox with confirmation is an additional measure.
  
In reality, the chance of losing the message is illusory, and during the testing, no such cases were identified.

In general, using authenticated mailboxes is optional and degrades performance, but allows priority mailboxes to be implemented.

### Priority mailbox

This is a special kind of delivery confirmation mailbox in which you can set the priority for messages. The priority determines the sequence in which messages will be sent to the Event Loop of the actor (its isolate).

The priority is set using the PriorityGenerator class.

Creating an actor with a priority mailbox (in the example, messages of type String have a higher priority than messages of type int), sending messages to it:

```dart
// Create actor class
class TestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });

    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);

      return;
    });
  }

  // Override createMailboxFactory method
  @override
  MailboxFactory createMailboxFactory() => PriorityReliableMailboxFactory(
      priorityGenerator: TestPriorityGenerator());
}

// Create priority generator class
class TestPriorityGenerator extends PriorityGenerator {
  @override
  int generatePriority(object) {
    if (object is String) {
      return 1;
    } else {
      return 0;
    }
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  var ref = await system.actorOf('test_actor', TestActor());

  for (var i = 0; i < 5; i++) {
    ref.send(i < 3 ? i : i.toString()); // Send messages 0, 1, 2, "3", "4"
  }
}
```
  
In the example above, 5 messages were sent to the actor - 0, 1, 2, "3", "4".

Expected output:

```dart
0
3
4
1
2
```

In the output, you can notice that all messages except the first are received by the actor in accordance with their priorities. This is due to the fact that the first message that hits the mailbox was sent to the actor before the rest of the messages reached the mailbox and before the priority queue in the mailbox was rebuilt in accordance with the message priorities.

The use of priority mailboxes, like delivery mailboxes, is optional and degrades performance, but combining them with untrusted mailboxes balances performance, reliability, and usability.

## Sending messages

In the theater, actors can send messages to each other via links to their mailboxes. The link can be obtained when creating an actor. However, there is a way to send a message to another actor without referring to it through his address, otherwise it would be inconvenient in the conditions of the hierarchical structure of the message upward.

### Send by link

Actor link encapsulates SendPort for sending a message to the actor's mailbox.

The link can be obtained both when creating a top-level actor using the actor system, and when creating a child actor through the actor context.

In these examples, we use the actor system to create a top-level actor and get a link to it, send a message to it:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  var ref = await system.actorOf('test_actor', TestActor());

  // Send 'Hello, from main!' message to actor
  ref.send('Hello, from main!');
}
```

In this example, we use the UntypedActor context to create its child actor, get a link to it and send a message to it.

```dart
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child with name 'second_test_actor'
    var ref = await context.actorOf('second_test_actor', SecondTestActor());

    // Send message
    ref.send('Luke, I am your father.');
  }
}

class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      if (message == 'Luke, I am your father.') {
        print('Nooooooo!');
      }

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

Thus, you can send messages to the actors by their links. Links, if desired, can be passed to other actors.

### Getting link

At Theater, you can send messages in several ways, one of which is sending a message via a link. You can get a link to an actor in the following ways:

- having created an actor you will receive a link to him;
- you can pass a link to an actor to another actor;
- you can get the link to the actor from the link register.

Getting a link to an actor when it is created.

When you create an actor using an actor system or an actor context, you get a local link to it.

An example of creating an actor using the system of actors and getting a link to it:

```dart
// Create actor class
class TestActor extends UntypedActor {}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor' and get ref to him
  var ref = await system.actorOf('test_actor', TestActor());
}
```

An example of creating an actor using the actor context and getting a link to it:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child actor with name 'second_test_actor' and get ref to him
    var ref = await context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor' and get ref to him
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

Passing an actor link to another actor.

In Theater, when you create an actor using an actor system or an actor context, you get a link to the actor. Using the link, you can send messages to the actor. If necessary, you can pass a link to an actor to another actor in a message or when creating an actor.

An example of creating two actors, transferring a link to actor №1 to actor №2 when creating actor №2, sending message from actor №2 to actor №1 using the link:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  late LocalActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Get ref from actor store
    _ref = context.store.get<LocalActorRef>('first_test_actor_ref');

    // Send message
    _ref.send('Hello, from second test actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  var ref = await system.actorOf('first_test_actor', FirstTestActor());

  var data = <String, dynamic>{'first_test_actor_ref': ref};

  // Create top-level actor in actor system with name 'second_test_actor'
  await system.actorOf('second_test_actor', SecondTestActor(), data: data);
}
```

Getting a link to an actor from the link register.

In Theater, you can send messages to actors in various ways, using links to them, as well as without a link. You get a link to an actor when creating an actor, and you can also transfer a link to another actor. However, sending links clearly may not be the most convenient way to get a link to an actor. Therefore, in the system of actors there is a place that stores references to all existing actors. This place is called - the register of links. Each actor, upon creation, adds a link to itself to the register. Using the actor system or actor context, you can get a reference to any actor from the register.

An example of getting a link to an actor from a register using the actor system:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  await system.actorOf('test_actor', TestActor());

  // Get ref to actor with relative path '../test_actor' from ref register
  // We use here relative path, but absolute path to actor with name 'test_actor' equal - 'test_system/root/user/test_actor'
  var ref = system.getLocalActorRef('../test_actor');

  ref?.send('Hello, from main!');
}
```

An example of getting a link to an actor from a register using the actor context:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });

    // Create child actor with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Get ref to actor with path 'test_system/root/user/first_test_actor' from ref register
    var ref = await context
        .getLocalActorRef('test_system/root/user/first_test_actor');

    // If ref exist (not null) send message
    ref?.send('Hello, from second actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

### Send without link

In Theater, you can send messages to actors using an actor link, the link you get when you create an actor using the actor system or through the actor context.

However, using a link may not always be convenient, for example, in cases where an actor will send a message to actors located in the actor tree above it.

To avoid such inconveniences, Theater has a special type of messages indicating the addressee. When an actor receives a message of this type on his mailbox, he verifies his address and the address specified in the message. If the message is not addressed to him, he, depending on the specified address, transmits this message up or down the tree of actors.

To send such a message, you need to use the send method of the actor system or the actor context. There are 2 types of set addresses:

- absolute;
- relative.

An absolute path is a full path to an actor starting from the name of the actor system, for example - "test_system/root/user/test_actor".

A relative path is a path that is specified relative to the path to the current actor (when sending a message through the actor context) or relative to the user guardian (in the case of sending a message through the actor system). An example of a relative path, if we send a message through the actor system, with an absolute path to the actor "test_system/root/user/test_actor" - "../test_actor".

An example of sending a message to an actor using the actor system using absolute path:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', TestActor());

  // Send message to actor using absolute path
  system.send('test_system/root/user/test_actor', 'Hello, from main!');
}
```

An example of sending a message to an actor using the actor system with a relative path:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', TestActor());

  // Send message to actor using relative path
  system.send('../test_actor', 'Hello, from main!');
}
```

An example of sending a message to an actor that is higher in the actor hierarchy, using the actor context with an absolute path:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });

    // Create actor child with name 'test_child'
    await context.actorOf('test_child', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Send message to parent using absolute path
    context.send('test_system/root/user/test_actor', 'Hello, from child!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', FirstTestActor());
}
```

An example of sending a message to an actor to a child using the actor context with a relative path:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create actor child with name 'test_child'
    await context.actorOf('test_child', SecondTestActor());

    // Send message to child using relative path
    context.send('../test_child', 'Hello, from parent!');
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', FirstTestActor());
}
```

### Receiving messages

Each actor can receive messages and handle them. To assign a handler to an actor to receive a message of a certain type, you can use the receive method in the actor context. Multiple handlers can be assigned to a message of the same type.

An example of creating an actor class and at the start of assigning a handler for receiving messages of type String and int:

```dart
// If you need use your class as message type
class Dog {
  final String name;

  Dog(this.name);
}

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });

    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);

      return;
    });

    context.receive<Dog>((message) async {
      print('Dog name: ' + message.name);

      return;
    });
  }
}
```

### Get message response

When sending messages to an actor using a link or without a link, there may be a need to receive a response to the message, this can be implemented by sending a SendPort in the message itself for a response, or in advance, when creating an actor, send a certain SendPort to it. Or, by sending messages without a link using absolute or relative paths, you can specify the path incorrectly, this will mean that the message will not find its addressee and it is desirable to be able to also understand when such a situation occurs. Theater has a mechanism for this - MessageSubscription.

When you send a message by reference or using a path, you get a MessageSubscription instance using the sendAndSubscribe method.

Using the onResponse method, you can assign a handler to receive a response about the status of a message.

Possible message states:

- DeliveredSuccessfullyResult - means that the message was successfully delivered to the actor, but he did not send you a response;
- RecipientNotFoundResult - means that there is no actor with this address in the actor tree;
- MessageResult - means that the message has been successfully delivered, the addressee has sent you a reply to your message.

An example of sending a message to an actor, receiving a response from it:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      // Print message
      print(message);

      // Send message result
      return MessageResult(data: 'Hello, from actor!');
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  var ref = await system.actorOf('actor', TestActor());

  // Send message 'Hello, from main!' to actor and get message subscription
  var subscription = ref.sendAndSubscribe('Hello, from main!');

  // Set onResponse handler
  subscription.onResponse((response) {
    if (response is MessageResult) {
      print(response.data);
    }
  });
}
```

Expected output:

```dart
Hello, from main!
Hello, from actor!
```

A message subscription encapsulates a ReceivePort, a regular message subscription closes its ReceivePort after receiving one result per message.

However, for example, when using router actors, you may need to accept multiple responses from different actors per message. Or if you have created multiple handlers for messages of the same type and you expect to receive multiple responses from both handlers.

To do this, you can turn MessageSubscription into MultipleMessageSubscription using the asMultipleSubscription () method. Such a subscription will not close its RecevePort after receiving the first message, however, this may create a not entirely transparent situation due to the use of ReceivePort inside the subscription, which you will need to close yourself using the cancel () method of the subscription - then when you no longer need the subscription.

### Listening messages by the actor system

In Theater, you can easily send a message from one actor to another, send or receive a reply to a sent message. But a situation may arise when you want to listen to messages from them without sending a message to the actors. For this, actor system has such a thing as Topics.

Using the ActorSystem class, you can subscribe to a topic of interest, as well as to messages of a certain type in this topic.

In this example, we create two actors, subscribe to messages of type String from the topic 'test_topic':

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Send message to actor system topic with name 'test_topic'
    context.sendToTopic('test_topic', 'Hello, from first test actor!');
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Send message to actor system topic with name 'test_topic'
    context.sendToTopic('test_topic', 'Hello, from second test actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create handler to messages as String from topic with name 'test_topic'
  system.listenTopic<String>('test_topic', (message) async {
    print(message);

    return;
  });

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());

  // Create top-level actor in actor system with name 'second_test_actor'
  await system.actorOf('second_test_actor', SecondTestActor());
}
```

Expected output:

```dart
Hello, from first test actor!
Hello, from second test actor!
```

In this example, we are subscribing to several different topics, as well as posting replies to messages from topic 'first_test_topic':

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Send message to actor system topic with name 'first_test_topic' and get subscription to response
    var subscription =
        context.sendToTopicAndSubscribe('first_test_topic', 'This is String');

    // Set handler to response
    subscription.onResponse((response) {
      if (response is MessageResult) {
        print(response.data);
      }
    });
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Send message to actor system topic with name 'second_test_topic'
    context.sendToTopic('second_test_topic', 123.4);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create handler to messages as String from topic with name 'first_test_topic'
  system.listenTopic<String>('first_test_topic', (message) async {
    print(message);

    return MessageResult(data: 'Hello, from main!');
  });

  // Create handler to messages as double from topic with name 'second_test_topic'
  system.listenTopic<double>('second_test_topic', (message) async {
    print(message * 2);

    return;
  });

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());

  // Create top-level actor in actor system with name 'second_test_actor'
  await system.actorOf('second_test_actor', SecondTestActor());
}
```

Excepted output:

```dart
This is String
Hello, from main!
246.8
```

### Message sending rate

In Theater, each actor is performed in his own isolate. Thus, the transfer of messages between them is carried out using the Send and Receive ports.

Each actor has his own mailbox in which messages sent to him come. Since the actor's mailbox is not in the same isolate as the actor itself, the speed of sending messages between actors in the Theater is lower than directly through the Send and Receive ports due to the additional forwarding of messages between the actor's mailbox and the actor itself.

The removal of the mailbox outside the actor's isolate was done so that when killing and restarting the actor, messages addressed to it that had not yet been processed by the actor would not be lost.

Thus, we get that sending messages between actors through the Theater facilities is at best slower than pure Send and Receive ports by about 2 times.

Also, the sending speed is affected by the fact that in Theater messages are transmitted between actors using message class instances, which also reduces the speed, unlike transmission via the Send and Receive port of simple types (int, double, String, etc.).

Theater has several ways to send a message to an actor:

- by link;
- without link.

In the case of sending a message using a link, the sent message is sent to the actor's mailbox from which, in accordance with the mechanism of operation of a particular mailbox, it enters the actor. This is the recommended method when using Theater.

In the case of sending a message without a link, the message is routed between actors along the tree of actors until it reaches its addressee. Earlier this method of sending messages was considered by me as the main one, but I did not take into account the loss of speed on each forwarding between each actor. Losses are especially evident in deep actor trees.

At the moment, sending messages without a link is still available in Theater, but I do not recommend using it where the speed of information transfer between actors is critically important to you. To make it easier to get a link to the actor you need, a register of links has been added, from which you can get a link to any actor. Although initially the concept of the register of links was not at the heart of Theater.

If the speed of information exchange between actors is critically important in your task and you are not satisfied with the same speed loss when using links to actors, you can also use Send and Receive ports on top of the Theater functionality in those places where you need the maximum speed of information transfer between isolates that can provide you with Dart.

## Routers

There is a special kind of actors in Theater - routers.

Such actors have child actors created according to their assigned deployment strategy. Forward all messages addressed to them to their child actors in accordance with their assigned message routing strategy. The main purpose of this type of actors is to create by balancing messages between actors.

There are 2 types of router actors in Theater:

- Group router;
- Pool router.

### Group Router

A group router is a router that creates a group of node actors as child actors (that is, UntypedActors or other routers can act as actors in this group). Unlike the pool router, it allows you to send messages to your child actors directly to them, that is, it is not necessary to send them messages only through the router.

Has the following message routing strategies:

- Broadcast. A message received by a router is forwarded to all actors in its group;
- Random. The message received by the router is forwarded to a random actor from its group;
- Round robin. Messages received by the router are sent to the actors from its group in a circle. That is, if 3 messages have arrived, and there are 2 actors in the group of actors, then 1 message will be received by actor №1, the second message - by actor №2, the third message - by actor №1.

An example of using a group router using a broadcast routing strategy:

```dart
// Create first test actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create router actor
    await context.actorOf('test_router', TestRouter());

    // Send message to router
    context.send('../test_router', 'Second hello!');

    // Send message to second without router
    context.send('../test_router/second_test_actor', 'First hello!');
  }
}

// Create router class
class TestRouter extends GroupRouterActor {
  // Override createDeployementStrategy method, configurate group router actor
  @override
  GroupDeployementStrategy createDeployementStrategy() {
    return GroupDeployementStrategy(
        routingStrategy: GroupRoutingStrategy.broadcast,
        group: [
          ActorInfo(name: 'second_test_actor', actor: SecondTestActor()),
          ActorInfo(name: 'third_test_actor', actor: ThirdTestActor())
        ]);
  }
}

// Create second test actor class
class SecondTestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Second actor received message: ' + message);

      return;
    });
  }
}

// Create third test actor class
class ThirdTestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Third actor received message: ' + message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

Expected output:

```dart
Second actor received message: Second hello!
Third actor received message: Second hello!
Second actor received message: First hello!
```

The structure of the actor tree in the actor system created in the example

<div align="center">

![](https://i.ibb.co/ZzHhr9q/group-router-example.png)

</div>

From the example you can see that we created an actor named 'first_test_actor', which created an actor-router named 'test_router' containing 2 actors in its group, sent 2 messages. The first message was sent to the router (it was later sent to all the actors in its group), the second message was sent only to the actor named 'second_test_actor'.

### Pool Router

A pool router is a router that, as child actors, creates a pool from the same type of worker actors assigned to it. Unlike a router, a group does not allow direct access to worker actors in its pool, that is, messages can be sent to them only through the router in accordance with the assigned routing strategy.

What is a worker actor? A worker actor is a special kind of actor used in a pool router. In general, that actor is similar to UntypedActor, but it cannot create child actors, and also has differences in its inner work.

Differences in internal work are expressed in the fact that the worker actor, after each processed message, after he has completed all the handlers assigned for the message, sends a report message to his actor manager. This creates additional traffic when using the pool router, but allows you to use its own routing strategy that allows you to more efficiently balance the load between the actors and workers in the pool.

Has the following message routing strategies:

- Broadcast. A message received by a router is forwarded to all actors in its group;
- Random. The message received by the router is forwarded to a random actor from its group;
- Round robin. Messages received by the router are sent to the actors from its group in a circle. That is, if 3 messages have arrived, and there are 2 actors in the group of actors, then 1 message will be received by actor No. 1, the second message - by actor No. 2, the third message - by actor No. 1;
- Load balancing. Balancing the load between workers in the pool, taking into account how many unprocessed messages each worker in the pool contains.

An example of creating a pool router using a random routing strategy:

```dart
// Create actor class
class TestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create router actor and get ref to him
    var ref = await context.actorOf('test_router', TestRouter());

    for (var i = 0; i < 5; i++) {
      // Send message to pool router
      ref.send('Hello message №' + i.toString());
    }
  }
}

// Create pool router class
class TestRouter extends PoolRouterActor {
  // Override createDeployementStrategy method, configurate group router actor
  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
        workerFactory: TestWorkerFactory(),
        routingStrategy: PoolRoutingStrategy.random,
        poolSize: 5);
  }
}

// Create actor worker class
class TestWorker extends WorkerActor {
  @override
  void onStart(WorkerActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Received by the worker with path: ' +
          context.path.toString() +
          ', message: ' +
          message);
      
      return;
    });
  }
}

// Create worker factory class
class TestWorkerFactory extends WorkerActorFactory {
  @override
  WorkerActor create() => TestWorker();
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with it
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await actorSystem.actorOf('test_actor', TestActor());
}
```

The structure of the actor tree in the actor system created in the example:

<div align="center">
  
![](https://i.ibb.co/nPNLyDk/pool-router-example.png)
  
</div>

One of the possible output results:

```dart
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-1, message: Hello message №1
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-2, message: Hello message №0
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-4, message: Hello message №2
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-2, message: Hello message №3
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-1, message: Hello message №4
```

# Transfer data to actor

In Theater, each actor has their own isolate. It follows from this that the data between the actors is not shared, but is transmitted by copying. And also the fact that when transferring data between actors, we have the same limitations as when using the Send and Receive ports directly.

You can send data using messages from one actor to another, but there are situations when we would like to immediately transfer some data to it when creating an actor.

This can be done in two ways:

- using the actor data store;
- using the actor class.

When creating an actor using the actor system or actor context, you can pass data to the actor using the data parameter. The passed data in the actor can be retrieved using the actor data store.

An example of passing data to an actor using the data parameter and the actor data store:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Get message from actor store
    var message = context.store.get<String>('message');

    print(message);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  var data = <String, dynamic>{'message': 'Hello, actor world'};

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor(), data: data);
}
```

I position the method of passing data to an actor using the data parameter and the actor data store as the main one (in the future I will improve it), but there is another way to pass data to the actor when it is created. This is the transfer of data to the actor class at the time of the creation of this class.

An example of passing data to an actor using an actor class:

```dart
class TestActor extends UntypedActor {
  final String _message;

  TestActor({required String message}) : _message = message;

  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    print(_message);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor(message: 'Hello, actor world!'));
}
```

# Supervising and error handling

In Theater, each actor, with the exception of the root one, has a parent actor who manages its life cycle and handles errors coming from it, as well as each actor with child actors acts as a superivor for its child actors.

Each supervisor has a control strategy (SupervisorStrategy), which handles the error received from the child actor and, in accordance with the exception that occurred in the child actor, receives an directive about what needs to be done with it.

Types of directive:

- Resume;
- Restart;
- Pause;
- Kill;
- Send an error to a supervisor actor (escalate).

Strategies are divided into 2 types:

- OneForOne;
- OneForAll.

The difference between these two strategies is that the OneForOne strategy applies the received instruction to the actor in which the error occurred, and the OneForAll strategy applies the instruction to all child actors of the actor making this decision. The OneForAll strategy can be useful in cases where an actor has several children whose work is very closely related to each other and an error in one should lead to a decision that is will be applied to all of them.

By default, each supervisor has a OneForOne strategy that communicates the error to the upstream supervisor. When the error reaches the user's guardian, he also passes it up to the root actor, which in turn passes the error to the actor system and the actor system killed all actors and throws an exception displaying the stack trace of all actors through which the error passed.

An example of error handling using the OneForOne strategy:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child actor with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }

  // Override createSupervisorStrategy method, set decider and restartDelay
  @override
  SupervisorStrategy createSupervisorStrategy() => OneForOneStrategy(
      decider: TestDecider(), restartDelay: Duration(milliseconds: 500));
}

// Create decider class
class TestDecider extends Decider {
  @override
  Directive decide(Object object) {
    if (object is FormatException) {
      return Directive.restart;
    } else {
      return Directive.escalate;
    }
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    print('Hello, from second test actor!');

    // Someone random factor or something where restarting might come in handy
    if (Random().nextBool()) {
      throw FormatException();
    }
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

In this example, the tree of actors and what happens in it when an error occurs can be represented as follows

<div align="center">

![](https://i.ibb.co/KwfMwwq/error-handling-example.png)

</div>

# Remoting [Beta]

In Theater, you can create actors that run in separate isolates and send messages to those actors. Such a message is sent locally, that is, in the actor system of the application that you launched.

But what about other actor systems that are running both locally and remotely on other devices in other Dart VMs?

In Theater, you can send messages to local actors that are in the same actor system. And remote, which are with them on one device or on another.

At the moment, remote interaction is available using the following protocols:

- tcp.

## Setup actor system

The actor system is configured at the time of its creation using the RemoteTransportConfiguration class.

The exchange of messages between actor systems is carried out one-way, that is, in the case when two actor systems exchange messages remotely, both actor systems are deployed to their servers and each of them creates an independent connection to the other actor system. That is, servers act as receivers of messages, and connections are necessary for sending.

An example of an actor system with a deployed Tcp server, created connection to another actor system:

```dart
void main() {
  // Create RemoteTransportConfiguration
  var remoteConfiguration = RemoteTransportConfiguration(
        connectors: [
          TcpConnectorConfiguration(
              name: 'second_actor_system', address: '127.0.0.1', port: 6655)
        ],
        servers: [
          TcpServerConfiguration(address: '127.0.0.1', port: 6656)
        ]);

  // Create actor system
  var system = ActorSystem('test_system', remoteConfiguration: remoteConfiguration);
}
```

### Serialization

Since messages transmitted between actor systems, regardless of the selected protocol, are transmitted in JSON format, it would be inconvenient when sending messages to constantly convert them to String on their own.

Dart lacks any JSON serializer/deserializer that works with objects without the need to write toJson and fromJson methods yourself, based on non-code generation.

Such a serializer can be implemented using the dart:mirros library, however, it is not available during AOT compilation and, accordingly, it and packages using it are not available in Flutter applications. Also, dart:mirros is not currently supported, and it's almost impossible to work with nullable types properly with it.

Therefore, I decided to add the ability to designate once, when creating an actor system, the logic of serialization and deserialization of messages incoming and outgoing from the actor system. Every message that enters or leaves the actor system goes through serialization and deserialization stage.

Each message incoming and outgoing from the actor system, in addition to the message content, also has a tag for more convenient serialization and deserialization.

An example of creating an actor system, setting up a RemoteTransportConfiguration with created serializer and deserializer, created by the connection:

```dart
// If you need create some class to use as a message
class User {
  final String name;

  final int age;

  User.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      age = json['age'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age
  };
}

// Create serializer class
class TestSerializer extends ActorMessageTransportSerializer {
  @override
  String serialize(String tag, dynamic data) {
    if (data is User) {
      return jsonEncode(data.toJson());
    } else {
      return data.toString();
    }
  }
}

// Create deserializer class
class TestDeserializer extends ActorMessageTransportDeserializer {
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'user') {
      return User.fromJson(jsonDecode(data));
    }
  }
}

void main() {
  // Create RemoteTransportConfiguration
  var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TestSerializer(),
        deserializer: TestDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'second_actor_system', address: '127.0.0.1', port: 6655)
        ]);

  // Create actor system
  var system = ActorSystem('test_system', remoteConfiguration: remoteConfiguration);
}
```

If serializers and deserializers were not specified when creating the actor system when setting up RemoteTransportConfiguration, then their default versions are used. The default version of the serializer tries to cast the sent object to a String, while the default deserializer returns the original received String.

## Getting remote link

In Theater, you can send messages to local actors using local actor link.

Similar to local actor references, in order to send a message to a remote actor, you must create a ref to the remote actor.

You can do this with an instance of the actor system or with an actor context.

An example of getting a ref to a remote actor using an actor context:

```dart
class TestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create remote actor ref by connection with name 'other_actor_system'
    // to actor with actor path 'other_actor_system/root/user/test_actor'
    var ref = await context.createRemoteActorRef('other_actor_system', 'other_actor_system/root/user/test_actor');
  }
}
```

In the above example, to get a ref to a remote actor, we need the name of our connection to the remote system of actors, and we must also specify the absolute path to the actor to which we send the message.

An example of getting a ref to a remote actor using an actor system:

```dart
void main() async {
  // Create remote transport configuration.
  var remoteConfiguration = RemoteTransportConfiguration(connectors: [
    TcpConnectorConfiguration(
        name: 'server_actor_system', address: '127.0.0.1', port: 6655)
  ]);

  // Create actor system
  var system = ActorSystem('client_actor_system', remoteConfiguration: remoteConfiguration);

  // Initialize actor system before work with it
  await system.initialize();

  // Create remote actor ref by connection with name 'server_actor_system'
  // to actor with actor path 'server_actor_system/root/user/test_actor'
  var ref = system.createRemoteActorRef(
      'server_actor_system', 'server_actor_system/root/user/test_actor');

  // Send message
  ref.send('test_message', 'Hello, from client!');
}
```

## Example

As an example of interaction between actor systems using Theater Remote, consider a situation in which two actor systems exchange messages, one sends a ping message to the other, and the second replies to it with a pong message.

As messages, we will send instances of the Ping and Pong classes, which will go through the stages of serialization and deserialization.

Creating a serializer and deserializer classes:

```dart
class Message {
  final String data;

  Message(this.data);

  Message.fromJson(Map<String, dynamic> json) : data = json['data'];

  Map<String, dynamic> toJson() => {'data': data};
}

// Create Ping class
class Ping extends Message {
  Ping(String data) : super(data);

  Ping.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

// Create Pong class
class Pong extends Message {
  Pong(String data) : super(data);

  Pong.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

// Create serializer class
class TransportSerializer extends ActorMessageTransportSerializer {
  // Override serialize method
  @override
  String serialize(String tag, dynamic data) {
    if (data is Message) {
      return jsonEncode(data.toJson());
    } else {
      return data.toString();
    }
  }
}

// Create deserializer class
class TransportDeserializer extends ActorMessageTransportDeserializer {
  // Override deserialize method
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'ping') {
      return Ping.fromJson(jsonDecode(data));
    } else if (tag == 'pong') {
      return Pong.fromJson(jsonDecode(data));
    } else {
      return data;
    }
  }
}
```

Creation of the first actor system:

```dart
// Create actor system builder class
class FirstActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'first_actor_system';

    // Create remote transport configuration.
    // Create in it connector and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'second_actor_system', address: '127.0.0.1', port: 6655)
        ],
        servers: [
          TcpServerConfiguration(address: '127.0.0.1', port: 6656)
        ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}

// Create actor class
class TestActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all Pong type messages which actor received
    context.receive<Pong>((message) async {
      print(message.data);

      return;
    });

    // Create remote actor ref by connection with name 'second_actor_system'
    // to actor with actor path 'second_actor_system/root/user/test_actor'
    _ref = await context.createRemoteActorRef(
        'second_actor_system', 'second_actor_system/root/user/test_actor');

    // Send message with tag 'ping'
    _ref.send('ping', Ping('Ping message from first actor system!'));
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = FirstActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

In the example, an ActorSystemBuilder class was created to create the actor system, this is not a mandatory measure. Added only to move the logic of creating and configuring the actor system into a separate class.

It can be seen from the example that the first actor system creates an actor that listens for messages of the Pong type, creates a ref to the remote actor and sends a Ping message to it.

Creation of the second system of actors:

```dart
// Create actor system builder class
class SecondActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'second_actor_system';

    // Create remote transport configuration.
    // Create in it connector and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'first_actor_system', address: '127.0.0.1', port: 6656)
        ],
        servers: [
          TcpServerConfiguration(address: '127.0.0.1', port: 6655)
        ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}

// Create actor class
class TestActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all Ping type messages which actor received
    context.receive<Ping>((message) async {
      print(message.data);

      // Send message with tag 'pong'
      _ref.send('pong', Pong('Pong message from second actor system!'));

      return;
    });

    // Create remote actor ref by connection with name 'first_actor_system'
    // to actor with actor path 'first_actor_system/root/user/test_actor'
    _ref = await context.createRemoteActorRef(
        'first_actor_system', 'first_actor_system/root/user/test_actor');
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = SecondActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

The second actor system creates an actor that listens for Ping messages, creates a ref to the remote actor, and when a Ping message is received, sends a Pong instance with a ref to the remote actor.

## Network security

Using Theater Remote, you can set network security settings for remote connections using the securityConfiguration parameter in the configuration classes for servers and connections. Depending on the type of protocol used in the created server or connection, the security settings that you can configure also change.

### Protocol TCP

The security settings for TCP servers and connections contain the following settings:

- securityContext;
- key;
- timeout.

With the help of securityContext you can set certificates and settings that the SecurityContext class in dart:io offers you for TCP connections.

However, in addition to the security features that the SecurityContext offers, there is also the ability to configure authorization for incoming connections using a key. The timeout parameter is responsible for how long such authorization will take before, in case of an unsuccessful authorization attempt, an error will be raised and the connection will be terminated.

# Utilities

## Scheduler

Scheduler is a class that makes it more convenient to create some tasks that have to be repeated after some time. Each actor context has its own scheduler instance, but you can create your own scheduler instance yourself.

With the scheduler, you can create scheduled actions. There are two types of actions:

- repeatedly action;
- one shot action.

### Repeatedly action

Sometimes it becomes necessary to perform some actions after a given period of time. For such cases, the Theater scheduler can create repeatedly actions.

In this example, we will create an actor that will print the message 'Hello, actor world!' To the console every second:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create repeatedly action in scheduler
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print('Hello, actor world!');
        });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

An action has a context that contains information about the action (for example, a counter for the number of times the action was triggered).

### Stop and resume repeatedly action

In the process of using repeatedly actions in the Theater scheduler, it may be necessary to stop a scheduled repeatedly action.

There is a recurring action token for this. With it, you can stop and resume scheduled actions.

An example of scheduling a recurring action and stopping it after 3 seconds using a token:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print(context.counter);
        },
        actionToken: actionToken);

    Future.delayed(Duration(seconds: 3), () {
      // Stop action
      actionToken.stop();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

You can use one token for any number of repeatedly actions.

An example of scheduling two repeatedly actions with one token, canceling them after 2 seconds and resuming 3 seconds after stopping:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print('Hello, from first action!');
        },
        onStop: (RepeatedlyActionContext context) {
          print('First action stopped!');
        },
        onResume: (RepeatedlyActionContext context) {
          print('First action resumed!');
        },
        actionToken: actionToken);

    // Create second repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print('Hello, from second action!');
        },
        onStop: (RepeatedlyActionContext context) {
          print('Second action stopped!');
        },
        onResume: (RepeatedlyActionContext context) {
          print('Second action resumed!');
        },
        actionToken: actionToken);

    Future.delayed(Duration(seconds: 2), () {
      // Stop action
      actionToken.stop();

      Future.delayed(Duration(seconds: 3), () {
        // Resume action
        actionToken.resume();
      });
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

With the help of a token, you can stop and resume repeatedly actions in the actor in which the token was created. But for situations in which you need to stop and resume actions in other actors, it is possible to get a link to the created token and pass it to another actor.

An example of scheduling a repeatedly action, getting a link to a token, passing a link to another actor, and canceling an action from another actor after 5 seconds using a link:

```dart
// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action in scheduler with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print(context.counter);
        },
        actionToken: actionToken);

    var data = <String, dynamic>{'action_token_ref': actionToken.ref};

    // Create child actor with name 'second_test_actor' and pass a ref during initialization
    await context.actorOf('second_test_actor', SecondTestActor(), data: data);
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Get action token ref from actor store
    var ref = context.store.get<RepeatedlyActionTokenRef>('action_token_ref');

    Future.delayed(Duration(seconds: 5), () {
      // Stop action in other actor
      ref.stop();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

### One shot action

In the scheduler, you can create one shot actions that are executed when they are called with or by reference to a token. Such actions can be useful when you want to launch an action or several actions (using one token) in an actor. Such actions do not provide for the transfer of any arguments for their launch.

An example of scheduling a one shot action and calling it using a token:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create one shot action token
    var actionToken = OneShotActionToken();

    // Create one shot action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from one shot action!');
        },
        actionToken: actionToken);

    // Call action
    actionToken.call();
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

If necessary, you can use one token for several single actions at once by running them together.

An example of planning two one shot actions with one token, calling them using a token:

```dart
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create one shot action token
    var actionToken = OneShotActionToken();

    // Create first action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from first action!');
        },
        actionToken: actionToken);

    // Create second action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from second action!');
        },
        actionToken: actionToken);

    // Call action
    actionToken.call();
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

As with using a token for repeatedly actions, you can get a reference to the token and pass it to another actor.

An example of scheduling one shot action, getting a link to its token, passing the link to another actor, and calling the action from another actor using the link:

```dart
// Create first actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create one shot action token
    var actionToken = OneShotActionToken();

    // Create one shot action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from one shot action!');
        },
        actionToken: actionToken);

    var data = <String, dynamic>{'action_token_ref': actionToken.ref};

    // Create child actor with name 'second_test_actor' and pass a ref during initialization
    await context.actorOf('second_test_actor', SecondTestActor(), data: data);
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Get action token ref from actor store
    var ref = context.store.get<OneShotActionTokenRef>('action_token_ref');

    // Call action in other actor
    ref.call();
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```
