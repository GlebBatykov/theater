# 0.1.52

- Updates README.md and README.ru.md.

## 0.1.51

- Fixes errors with missing files when publishing.

## 0.1.5

- Duplicates each method of sending a message to another actor. There is a version with a subscription to the state of the message (and to reply to messages) and without a subscription. It was done because it is not always necessary to monitor the status or response of a message, but this process creates additional traffic and degrades the speed of sending the application, the performance of the application. Therefore, use the subscription only when you need it.

- Adds new way to get ref to actor. Now with ActorContext and ActorSystem, you can get the link to other actor.

- Improves scheduler. In addition to repeatedly actions, there are one shot actions.
  - CancellationToken replace to RepeatedlyActionToken for repeatedly actions and OneShotActionToken for one shot actions.
  - For OneShotActionToken and RepeatedlyActionToken add the ability to receive links to them and transfer them to other actors (isolates).
    - Using OneShotActionTokenRef, you can call one shot action from another actor.
    - Using RepatedlyActionTokenRef, you can stop and resume RepeatedlyAction from another actor.

- Adds new place where is the data passed to the actor when the actor is created. The old way to get this data is marked deprecated.

- Adds a new type of actor - system actor (previously, they were not explicitly present).

- Updates documentation.
- Updates and adds examples.
- Adds tests.

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
