import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:jama/data/core/db/db_collection.dart';
import 'package:jama/data/core/db/query_package.dart';
import 'package:jama/data/models/placement_model.dart';
import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/data/models/visit_model.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/services/image_service.dart';

import 'package:kiwi/kiwi.dart';

class ReturnVisitService {
  ImageService _imageService;

  final String _returnVisitDatabaseName = "returnvisits";
  final String _visitsDatabaseName = "visits";
  final Completer<DbCollection> _returnVisitCollection = Completer();
  final Completer<DbCollection> _visitsCollection = Completer();
  final StreamController<void> _returnVisitsUpdated = StreamController.broadcast();

  /// Get the stream of events indicating the return visits have changed.
  Stream get returnVisitUpdates => _returnVisitsUpdated.stream;

  ReturnVisitService([ImageService imageService, DatabaseService databaseService]) {
    var container = Container();

    var dbService = databaseService ?? container.resolve<DatabaseService>();
    _imageService = imageService ?? container.resolve<ImageService>();

    var getReturnVisitCollection = () async {
      final db = await dbService.getMainStorage();
      return db.collections(_returnVisitDatabaseName);
    };
    
    _returnVisitCollection.complete(getReturnVisitCollection());

    var getVisitsCollection = () async {
      final db = await dbService.getMainStorage();
      return db.collections(_visitsDatabaseName);
    };

    _visitsCollection.complete(getVisitsCollection());
  }

  /// Add [rv] as a new return visit.
  /// 
  /// The [rv] and [initialCallDate] are required.
  Future<ReturnVisit> addNewReturnVisit({
    @required ReturnVisit rv, 
    @required DateTime initialCallDate, 
    List<Placement> initialCallPlacements, 
    String initialCallNotes}) async {
    assert(initialCallDate != null);
    assert(rv != null);

    var returnVisitDb = await _returnVisitCollection.future;
    var rvId = await returnVisitDb.add(rv);
    assert(rvId != null);
    assert(rvId >= 0);
    
    rv.id = rvId;
    rv.lastVisitDate = initialCallDate.millisecondsSinceEpoch;
    
    var initialCall = Visit(
      date: initialCallDate,
      parentRvId: rvId,
      notes: initialCallNotes,
      type: VisitType.ReturnVisit,
      placements: initialCallPlacements);
    
    var visitsDb = await _visitsCollection.future;
    
    rv.lastVisitId = await visitsDb.add(initialCall);

    assert(rv.lastVisitId != null);
    assert(rv.lastVisitId >= 0);

    await returnVisitDb.update(rv);

    _returnVisitsUpdated.add(null);
    return rv;
  }

  Future<List<ReturnVisit>> getAllReturnVisits() async {
    var returnVisitsDb = await _returnVisitCollection.future;
    return await returnVisitsDb.getAll((map) => ReturnVisit.fromMap(map));
  }

  Future<List<Visit>> getAllVisitsForRv(ReturnVisit rv) async {
    var visitsDb = await _visitsCollection.future;
    return await visitsDb.query([
      QueryPackage(
        key: "parentRvId",
        value: rv.id,
        filter: FilterType.EqualTo)
    ], 
    (map) => Visit.fromMap(map));
  }

  Future delete(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv.id > 0);
    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.deleteFromDto(rv);

    var visits = await getAllVisitsForRv(rv);
    var visitsDb = await _visitsCollection.future;
    for(var visit in visits) {
      await visitsDb.deleteFromDto(visit);
    }

    if(rv.imagePath.isNotEmpty) {
      var imageFile = await _imageService.getImageFile(rv.imagePath);
      await imageFile.delete();
    }

    _returnVisitsUpdated.add(null);
  }

  Future updateReturnVisit(ReturnVisit rv) async {
    assert(rv != null);
    assert(rv.id > 0);
    assert(rv.lastVisitDate != null);
    assert(rv.lastVisitId > 0);

    var returnVisitsDb = await _returnVisitCollection.future;
    await returnVisitsDb.update(rv);

    _returnVisitsUpdated.add(null);
  }
}