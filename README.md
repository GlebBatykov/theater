<div align="center" width="200px">

![](https://github.com/GlebBatykov/theater/blob/main/logo.png?raw=true)

Actor model implementation in Dart
  
</div>

<div align="center">

**Languages:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](README.ru.md)
  
</div>  

- [Introduction](#introduction)
- [About Theater](#about-theater)
- [Installing](#installing)
- [What is Actor](#what-is-actor)
  - [Notes about the actors](#notes-about-the-actors)
- [Actor system](#actor-system)
  - [Actor tree](#actor-tree)
  - [Using Actors](#using-actors)
- [Actor types](#actor-types)
- [Routing](#routing)
  - [Mailboxes](#mailboxes)
    - [Unreliable mailbox](#unreliable-mailbox)
    - [Reliable mailbox](#reliable-mailbox)
    - [Priority mailbox](#priority-mailbox)
  - [Sending messages](#sending-messages)
    - [Send by link](#send-by-link)
    - [Send without link](#send-without-link)
    - [Receiving messages](#receiving-messages)
    - [Get message response](#get-message-response)
    - [Listening messages by the actor system](#listening-messages-by-the-actor-system)
  - [Routers](#routers)
    - [Group router](#group-router)
    - [Pool router](#pool-router)
- [Supervising and error handling](#supervising-and-error-handling)
- [Utilities](#utilities)
  - [Scheduler](#scheduler)
- [Road map](#road-map)

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
- ability to load balance (messages) between actors, creating pools of actors.

Currently in development is the ability to send a message over the network to actor systems located in other Dart VMs.

# Installing

Add Theater to your pubspec.yaml file:

```dart
dependencies:
  theater: ^0.1.3
```

Import theater in files that it will be used:

```dart
import 'package:theater/theater.dart';
```

# What is Actor

An actor is an entity that has a behavior and is executed in a separate isolate. It has its own unique address (path) in the actor system. He can receive and send messages to other actors using links to them or using only their address (path) in the actor system. Each actor has methods called during its lifecycle (which repeat the lifecycle of its isolate):

- onStart(). Called after the actor starts;
- onPause(). Called before the actor is paused;
- onResume(). Called after the actor is revived;
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
  Future<void> onStart(UntypedActorContext context) async {
    // Print 'Hello, world!'
    print('Hello, world!');
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
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
- Supervisor actor is a node of the tree;
- Observed actor is a sheet of the tree.

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
  Future<void> onStart(UntypedActorContext context) async {
    print(context.path);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with her
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await actorSystem.actorOf('test_actor', TestActor());
}
```

Expected output:

```dart
tcp://test_system/root/user/test_actor
```

In the example, the full path to the actor also has "tcp" at the beginning. What does this mean? Currently in development is the ability to communicate through the network of several systems of actors in different Dart VMs. The prefix at the beginning of the path to the actor will mean the network protocol in the actor system for other actor system communication over the network.

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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });

    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);
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

  // Initialize actor system before work with her
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      if (message == 'Luke, I am your father.') {
        print('Nooooooo!');
      }
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

Thus, you can send messages to the actors by their links. Links, if desired, can be passed to other actors.

### Send without link

In Theater, you can send messages to actors using an actor link, the link you get when you create an actor using the actor system or through the actor context.

However, using a link may not always be convenient, for example, in cases where an actor will send a message to actors located in the actor tree above it.

To avoid such inconveniences, Theater has a special type of messages indicating the addressee. When an actor receives a message of this type on his mailbox, he verifies his address and the address specified in the message. If the message is not addressed to him, he, depending on the specified address, transmits this message up or down the tree of actors.

To send such a message, you need to use the send method of the actor system or the actor context. There are 2 types of set addresses:
- Absolute;
- Relative.

An absolute path is a full path to an actor starting from the name of the actor system, for example - "test_system/root/user/test_actor".

A relative path is a path that is specified relative to the path to the current actor (when sending a message through the actor context) or relative to the user guardian (in the case of sending a message through the actor system). An example of a relative path, if we send a message through the actor system, with an absolute path to the actor "test_system/root/user/test_actor" - "../test_actor".

An example of sending a message to an actor using the actor system using absolute path:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
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
    });

    // Create actor child with name 'test_child'
    await context.actorOf('test_child', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to parent using absolute path
    context.send('test_system/root/user/test_actor', 'Hello, from child!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', FirstTestActor());
}
```

### Receiving messages

Each actor can receive messages and handle them. To assign a handler to an actor to receive a message of a certain type, you can use the receive method in the actor context. Multiple handlers can be assigned to a message of the same type.

An example of creating an actor class and at the start of assigning a handler for receiving messages of type String and int:


```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
    
    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);
    });
  }
}
```

### Get message response

When sending messages to an actor using a link or without a link, there may be a need to receive a response to the message, this can be implemented by sending a SendPort in the message itself for a response, or in advance, when creating an actor, send a certain SendPort to it. Or, by sending messages without a link using absolute or relative paths, you can specify the path incorrectly, this will mean that the message will not find its addressee and it is desirable to be able to also understand when such a situation occurs. Theater has a mechanism for this - MessageSubscription.

When you send a message by reference or using a path, you always get a MessageSubscription instance using the send method of the actor system or actor context.

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
  Future<void> onStart(context) async {
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

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  var ref = await system.actorOf('actor', TestActor());

  // Send message 'Hello, from main!' to actor and get message subscription
  var subscription = ref.send('Hello, from main!');

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
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'test_topic'
    context.sendToTopic('test_topic', 'Hello, from first test actor!');
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'test_topic'
    context.sendToTopic('test_topic', 'Hello, from second test actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create handler to messages as String from topic with name 'test_topic'
  system.listenTopic<String>('test_topic', (message) async {
    print(message);
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
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'first_test_topic' and get subscription to response
    var subscription =
        context.sendToTopic('first_test_topic', 'This is String');

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
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'second_test_topic'
    context.sendToTopic('second_test_topic', 123.4);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create handler to messages as String from topic with name 'first_test_topic'
  system.listenTopic<String>('first_test_topic', (message) async {
    print(message);

    return MessageResult(data: 'Hello, from main!');
  });

  // Create handler to messages as double from topic with name 'second_test_topic'
  system.listenTopic<double>('second_test_topic', (message) async {
    print(message * 2);
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Second actor received message: ' + message);
    });
  }
}

// Create third test actor class
class ThirdTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Third actor received message: ' + message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with her
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await actorSystem.actorOf('first_test_actor', FirstTestActor());
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
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Received by the worker with path: ' +
          context.path.toString() +
          ', message: ' +
          message);
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

  // Initialize actor system before work with her
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await actorSystem.actorOf('test_actor', TestActor());
}
```

The structure of the actor tree in the actor system created in the example:

<div align="center">
  
![](https://i.ibb.co/nPNLyDk/pool-router-example.png)
  
</div>

One of the possible output results

```dart
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-1, message: Hello message №1
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-2, message: Hello message №0
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-4, message: Hello message №2
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-2, message: Hello message №3
Received by the worker with path: tcp://test_system/root/user/test_actor/test_router/worker-1, message: Hello message №4
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
  Directive decide(Exception exception) {
    if (exception is FormatException) {
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
  Future<void> onStart(UntypedActorContext context) async {
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

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
```

In this example, the tree of actors and what happens in it when an error occurs can be represented as follows

<div align="center">

![](https://i.ibb.co/KwfMwwq/error-handling-example.png)

</div>

# Utilities

## Scheduler

Scheduler is a class that makes it more convenient to create some tasks that have to be repeated after some time. Each actor context has its own scheduler instance, but you can create your own scheduler instance yourself.

In Dart, tasks that are executed periodically after some time are very easy to implement using Timer, so in Theater the scheduler is just a convenient abstraction for this. For example, the Theater scheduler allows you to cancel multiple tasks at once using a CancellationToken.

At the moment, the scheduler is under development and it is planned to add to it, for example, the ability to transfer cancellation tokens to other actors (at the moment this is not possible), this will allow canceling scheduled tasks from other actors.

An example of creating tasks using the scheduler, canceling scheduled tasks after 3 seconds using the cancellation token:

```dart
// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create cancellation token
    var cancellationToken = CancellationToken();

    // Create first repeatedly action in scheduler
    context.scheduler.scheduleActionRepeatedly(
        interval: Duration(seconds: 1),
        action: () {
          print('Hello, from first action!');
        },
        cancellationToken: cancellationToken);

    // Create second repeatedly action in scheduler
    context.scheduler.scheduleActionRepeatedly(
        initDelay: Duration(seconds: 1),
        interval: Duration(milliseconds: 500),
        action: () {
          print('Hello, from second action!');
        },
        cancellationToken: cancellationToken);

    Future.delayed(Duration(seconds: 3), () {
      // Cancel actions after 3 seconds
      cancellationToken.cancel();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
```

Expected output:

```dart
Hello, from first action!
Hello, from second action!
Hello, from first action!
Hello, from second action!
Hello, from second action!
```

# Road map

Currently in development are:
- communication with actor systems located in other Dart VMs via the network (udp, tcp);
- improvement of the message routing system (more functions and, if necessary, optimization);
- improvement of the error handling system, error logging.
