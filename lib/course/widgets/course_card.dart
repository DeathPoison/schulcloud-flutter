import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({@required this.course}) : assert(course != null);

  final Course course;

  void _openDetailsScreen(BuildContext context) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => CourseDetailsScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => _openDetailsScreen(context),
      color: course.color.withOpacity(0.12),
      child: Row(
        children: <Widget>[
          Text(course.name),
          Expanded(
            child: CachedRawBuilder(
              controllerBuilder: () =>
                  services.get<CourseBloc>().fetchTeachersOfCourse(course),
              builder: (_, update) {
                final teachers = update.data;
                return Text(
                  (teachers ?? [])
                      .map((teacher) => teacher.shortName)
                      .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ],
        // leading: Container(color: course.color, width: 16),
      ),
    );
  }
}
