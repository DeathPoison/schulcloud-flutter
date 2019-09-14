import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/routes.dart';

import '../data.dart';
import '../services.dart';

class Menu extends StatefulWidget {
  final Routes activeScreen;

  const Menu({this.activeScreen});
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  void _navigateTo(Routes target) => Navigator.pop(context, target.name);

  Future<void> _logOut() async {
    await Provider.of<AuthenticationStorageService>(context).logOut();
    Navigator.of(context).pushReplacementNamed(Routes.login.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildUserInfo(),
          Divider(),
          ..._buildNavigationItems(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return StreamBuilder<User>(
      stream: Provider.of<MeService>(context).meStream,
      builder: (context, snapshot) {
        var meService = Provider.of<MeService>(context);
        if (!snapshot.hasData) {
          return Text('Not logged in yet.');
        }
        var user = snapshot.data;

        return Row(
          children: <Widget>[
            SizedBox(width: 16.0 + 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: TextStyle(fontSize: 16)),
                  Text(user.email, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.airline_seat_legroom_reduced),
              onPressed: _logOut,
            ),
            SizedBox(width: 8),
          ],
        );
      },
    );
  }

  List<Widget> _buildNavigationItems() {
    return [
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.dashboard, color: color),
        text: 'Dashboard',
        onPressed: () => _navigateTo(Routes.dashboard),
        isActive: widget.activeScreen == Routes.dashboard,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.new_releases, color: color),
        text: 'News',
        onPressed: () => _navigateTo(Routes.news),
        isActive: widget.activeScreen == Routes.news,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.school, color: color),
        text: 'Courses',
        onPressed: () => _navigateTo(Routes.courses),
        isActive: widget.activeScreen == Routes.courses,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.folder, color: color),
        text: 'Files',
        onPressed: () => _navigateTo(Routes.files),
        isActive: widget.activeScreen == Routes.files,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.list, color: color),
        text: 'Login',
        onPressed: () => _navigateTo(Routes.login),
        isActive: widget.activeScreen == Routes.login,
      ),
    ];
  }
}

class NavigationItem extends StatelessWidget {
  NavigationItem({
    @required this.iconBuilder,
    @required this.text,
    @required this.onPressed,
    @required this.isActive,
  })  : assert(iconBuilder != null),
        assert(text != null),
        assert(onPressed != null),
        assert(isActive != null);

  final Widget Function(Color color) iconBuilder;
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    var color = isActive ? Theme.of(context).primaryColor : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                iconBuilder(color),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
