.. _view-model-view:

****************
View model, view
****************

The view model and the view are simple C++ classes in an MVVM architecture.

View model
----------

The MainViewModel class included in the skeleton file contains a HsAppStateWrapper pointer. This automatically gets initialised on construction and deleted on destruction.

Here, you should add the members and methods you would usually include in an MVVM view model. For example, if you are to have a programatically controlled label in the view, you can add an ``std::string`` member to the view model and a getter for getting its content; this will correspond to the content of the label.

For utilising Futures, there is an example implementation using an ``std::thread`` and a Future pointer to handle them safely and easily. See the section on :ref:`futures` to learn more.

View
----

The view is usually simply a Qt-based GUI put on top of the view model discussed before. In the skeleton project, the MainWindow class creates a MainViewModel instance on construction and deletes it on destruction; similarly to what we have seen at the view model itself for HsAppStateWrapper.

There are not many features here anymore that would be specific to Agdalache; if you have used Qt, it will be familiar to you. This means that you can freely delegate this part even to someone who has not ever used functional languages before!
