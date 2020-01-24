import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/data.dart';
import 'package:schulcloud/l10n/l10n.dart';

import '../assignment.dart';
import '../bloc.dart';

class AssignmentDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: context.s.assignment_dashboardCard,
      child: CachedRawBuilder<List<Assignment>>(
        controller: services.get<AssignmentBloc>().fetchAssignments(),
        builder: (context, update) {
          if (!update.hasData) {
            return Center(
              child: update.hasError
                  ? Text(update.error.toString())
                  : CircularProgressIndicator(),
            );
          }

          // Only show open assignments that are due in the next week
          var openAssignments = update.data.where((h) =>
              h.dueDate.isAfter(DateTime.now()) &&
              h.dueDate.isBefore(DateTime.now().add(Duration(days: 7))));

          // Assignments are shown grouped by subject
          var subjects = groupBy<Assignment, Id<Course>>(
              openAssignments, (h) => h.courseId);

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    openAssignments.length.toString(),
                    style: Theme.of(context).textTheme.display3,
                  ),
                  SizedBox(width: 4),
                  Text(
                    context.s.assignment_dashboardCard_header(
                        openAssignments.length),
                    style: Theme.of(context).textTheme.subhead,
                  )
                ],
              ),
              ...ListTile.divideTiles(
                context: context,
                tiles: subjects.keys.map(
                  (c) => CachedRawBuilder<Course>(
                    controller: services.get<CourseBloc>().fetchCourse(c),
                    builder: (context, update) {
                      if (!update.hasData) {
                        return ListTile(
                          title: Text(update.hasError
                              ? update.error.toString()
                              : context.s.general_loading),
                        );
                      }

                      var course = update.data;

                      return ListTile(
                        leading: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: course.color,
                          ),
                        ),
                        title: Text(course.name),
                        trailing: Text(
                          subjects[c].length.toString(),
                          style: context.textTheme.headline,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlineButton(
                    onPressed: () {
                      context.navigator.push(MaterialPageRoute(
                          builder: (context) => AssignmentsScreen()));
                    },
                    child: Text(context.s.assignment_dashboardCard_all),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
