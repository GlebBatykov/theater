# 0.2.5

- Actor:
  - BREAKING CHANGE: rename property of ActorContext - itself to self.
- Supervising:
  - BREAKING CHANGE: the Directive enumeration has been replaced with the Directive base class, and all directives are now classes inherited from the Directive class.
  - BREAKING CHANGE: now the actor in which the error occurred is not paused automatically before processing the error.
  - BREAKING CHANGE: remove resume directive.
  - Add ignore directive.
- Add getActorsPaths method to actor context. Used to get paths to all actors in the actor system.
- Remote:
  - Update remote features.
- Logging:
  - Add logging features.
- Dispatch:
  - Add getFirstResult method to MessageSubscription class.
- Util:

- Add new tests.
- Update README files.

## 0.2.21

- Update README files.

## 0.2.2

- Update README files.
- Update examples.
- Make minor fixes.

## 0.2.13

- Make minor fixes.
- Update README files.

## 0.2.12

- Make minor fixes.
- Update README files.

## 0.2.11

- Make minor fixes.
- Update README files.

## 0.2.1

- Update README files.
- Update examples.
- Make minor fixes.
- Update logo.

## 0.2.0

- Add the possibility of remote interaction of actors - Theater Remote. Theater Remote is currently in beta.
- Add the ability to manage the lifecycle of actors. Adds methods for managing the lifecycle of child actors to the context of the actor. Adds the ability to completely remove actors from the actor tree.
- Change and fixes of the register of refs.
- Make corrections and fixes errors in the error handling system.
- Add examples.
- Update README files.
- Update documentation.
- Add testes.
- Add other minor changes.

## 0.1.52

- Update README.md and README.ru.md.

## 0.1.51

- Fixe errors with missing files when publishing.

## 0.1.5

- BREAKING CHANGE: duplicate each method of sending a message to another actor. There is a version with a subscription to the state of the message (and to reply to messages) and without a subscription. It was done because it is not always necessary to monitor the status or response of a message, but this process creates additional traffic and degrades the speed of sending the application, the performance of the application. Therefore, use the subscription only when you need it.

- Add new way to get ref to actor. Now with ActorContext and ActorSystem, you can get the link to other actor.

- Improve scheduler. In addition to repeatedly actions, there are one shot actions.
  - CancellationToken replace to RepeatedlyActionToken for repeatedly actions and OneShotActionToken for one shot actions.
  - For OneShotActionToken and RepeatedlyActionToken add the ability to receive links to them and transfer them to other actors (isolates).
    - Using OneShotActionTokenRef, you can call one shot action from another actor.
    - Using RepatedlyActionTokenRef, you can stop and resume RepeatedlyAction from another actor.

- Add new place where is the data passed to the actor when the actor is created. The old way to get this data is marked deprecated.

- Add a new type of actor - system actor (previously, they were not explicitly present).

- Update documentation.
- Update and adds examples.
- Add tests.

## 0.1.3

- Add example.
- Fix documentation.

## 0.1.2

- Add tests.
- Add documentation.

## 0.1.1

- Fix info to README files, documentation. Add more info to tests. Add longer package description to pubspec.yaml file.
- Add new way to receive messages from the actor system - topics.

## 0.1.0

- Initial version.
