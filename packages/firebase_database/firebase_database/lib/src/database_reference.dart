// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// DatabaseReference represents a particular location in your Firebase
/// Database and can be used for reading or writing data to that location.
///
/// This class is the starting point for all Firebase Database operations.
/// After you’ve obtained your first DatabaseReference via
/// `FirebaseDatabase.reference()`, you can use it to read data
/// (ie. `onChildAdded`), write data (ie. `setValue`), and to create new
/// `DatabaseReference`s (ie. `child`).
class DatabaseReference extends Query {
  platform.DatabaseReference _delegate;
  DatabaseReference._(this._delegate, List<String> pathComponents)
      : super(delegate: _delegate, pathComponents: pathComponents);

  /// Gets a DatabaseReference for the location at the specified relative
  /// path. The relative path can either be a simple child key (e.g. ‘fred’) or
  /// a deeper slash-separated path (e.g. ‘fred/name/first’).
  DatabaseReference child(String path) {
    return DatabaseReference._(_delegate,
        (List<String>.from(_pathComponents)..addAll(path.split('/'))));
  }

  /// Gets a DatabaseReference for the parent location. If this instance
  /// refers to the root of your Firebase Database, it has no parent, and
  /// therefore parent() will return null.
  DatabaseReference parent() {
    if (_pathComponents.isEmpty) {
      return null;
    }
    return DatabaseReference._(
        _delegate, (List<String>.from(_pathComponents)..removeLast()));
  }

  /// Gets a FIRDatabaseReference for the root location.
  DatabaseReference root() {
    return DatabaseReference._(_delegate, <String>[]);
  }

  /// Gets the last token in a Firebase Database location (e.g. ‘fred’ in
  /// https://SampleChat.firebaseIO-demo.com/users/fred)
  String get key => _pathComponents.last;

  /// Generates a new child location using a unique key and returns a
  /// DatabaseReference to it. This is useful when the children of a Firebase
  /// Database location represent a list of items.
  ///
  /// The unique key generated by childByAutoId: is prefixed with a
  /// client-generated timestamp so that the resulting list will be
  /// chronologically-sorted.
  DatabaseReference push() {
    final String key = PushIdGenerator.generatePushChildName();
    final List<String> childPath = List<String>.from(_pathComponents)..add(key);
    return DatabaseReference._(_delegate, childPath);
  }

  /// Write `value` to the location with the specified `priority` if applicable.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// Data types that are allowed are String, boolean, int, double, Map, List.
  ///
  /// The effect of the write will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the data to the Firebase
  /// Database servers will also be started.
  ///
  /// Passing null for the new value means all data at this location or any
  /// child location will be deleted.
  Future<void> set(dynamic value, {dynamic priority}) {
    return _delegate.set(value, priority: priority);
  }

  /// Update the node with the `value`
  Future<void> update(Map<String, dynamic> value) {
    return _delegate.update(value);
  }

  /// Sets a priority for the data at this Firebase Database location.
  ///
  /// Priorities can be used to provide a custom ordering for the children at a
  /// location (if no priorities are specified, the children are ordered by
  /// key).
  ///
  /// You cannot set a priority on an empty location. For this reason
  /// set() should be used when setting initial data with a specific priority
  /// and setPriority() should be used when updating the priority of existing
  /// data.
  ///
  /// Children are sorted based on this priority using the following rules:
  ///
  /// Children with no priority come first. Children with a number as their
  /// priority come next. They are sorted numerically by priority (small to
  /// large). Children with a string as their priority come last. They are
  /// sorted lexicographically by priority. Whenever two children have the same
  /// priority (including no priority), they are sorted by key. Numeric keys
  /// come first (sorted numerically), followed by the remaining keys (sorted
  /// lexicographically).
  ///
  /// Note that priorities are parsed and ordered as IEEE 754 double-precision
  /// floating-point numbers. Keys are always stored as strings and are treated
  /// as numbers only when they can be parsed as a 32-bit integer.
  Future<void> setPriority(dynamic priority) async {
    return _delegate.setPriority(priority);
  }

  /// Remove the data at this Firebase Database location. Any data at child
  /// locations will also be deleted.
  ///
  /// The effect of the delete will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the delete to the Firebase
  /// Database servers will also be started.
  ///
  /// remove() is equivalent to calling set(null)
  Future<void> remove() => set(null);

  /// Performs an optimistic-concurrency transactional update to the data at
  /// this Firebase Database location.
  Future<TransactionResult> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    throw UnsupportedError("runTransaction() is not supported ccurrently.");
    // platform.TransactionResult result = (await _delegate.runTransaction(
    //     (platformTransaction) => transactionHandler(Transaction),
    //     timeout: timeout));
    // return TransactionResult._(DatabaseError._(result.error), result.committed,
    //     DataSnapshot._(result.dataSnapshot));
  }

  OnDisconnect onDisconnect() {
    return OnDisconnect._(_delegate.onDisconnect());
  }
}

class ServerValue {
  static const Map<String, String> timestamp = <String, String>{
    '.sv': 'timestamp'
  };
}

typedef Future<MutableData> TransactionHandler(MutableData mutableData);

class TransactionResult {
  const TransactionResult._(this.error, this.committed, this.dataSnapshot);
  final DatabaseError error;
  final bool committed;
  final DataSnapshot dataSnapshot;
}
