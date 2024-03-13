import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/photo.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';
import 'package:mess_app_staff/utils/constants.dart';

class UserScreen extends StatefulWidget {
  final API api;
  final String kerberos;
  final String token;
  const UserScreen({
    super.key,
    required this.api,
    required this.kerberos,
    required this.token,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<dynamic> activeMeals = [];
  List<dynamic> allMeals = [];
  late Map<String, dynamic> userProfile;
  Map<String, dynamic>? user;
  String? msg;

  Future<void> getDetails() async {
    userProfile = await widget.api.verifyToken(widget.kerberos, widget.token);

    if (userProfile.containsKey('token')) {
      setState(() => user = userProfile['token']['user_id']);
      setState(() => activeMeals = userProfile['active_meals']);
      widget.api
          .getMealTokens(widget.kerberos)
          .then((value) => setState(() => allMeals = value));
    } else {
      setState(() => msg = "ERROR: $userProfile");
    }
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Details"),
          actions: [
            ElevatedButton(
                onPressed: () => as1605.navPush(
                    context,
                    (_) => PhotoScreen(
                        api: widget.api,
                        kerberos: widget.kerberos,
                        token: widget.token)),
                child: const Text("Edit")),
            const SizedBox(width: 10)
          ],
        ),
        body: (msg == null)
            ? ListView(
                padding: const EdgeInsets.all(15),
                children: [
                      (user == null)
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : UserCard(user: user!),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                            activeMeals == []
                                ? 'No Active Meals'
                                : 'Active Meals',
                            style: const TextStyle(fontSize: 25)),
                      ),
                    ] +
                    activeMeals
                        .map((e) => MealCard(
                            mealToken: e, api: widget.api, active: true))
                        .toList() +
                    [
                      const SizedBox(height: 20),
                      Center(
                          child: Text(allMeals == [] ? 'No Meals' : 'All Meals',
                              style: const TextStyle(fontSize: 25))),
                    ] +
                    allMeals
                        .map((e) => MealCard(
                            mealToken: e, api: widget.api, active: false))
                        .toList())
            : Text(msg!));
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
      const SizedBox(height: 20),
      Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: user['photo'] == null
              ? const Icon(Icons.person, size: 200)
              : CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain)),
                  ),
                  imageUrl:
                      "${STRINGS.serverUrl}/staff/photo/${user['photo'].split('/').last}",
                  httpHeaders: {'Cookie': 'connect.sid=${user['cookie']}'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  height: 200,
                  width: 200,
                )),
      ListTile(
        leading: Icon(
          Icons.circle,
          color: user['isActive'] == true ? Colors.green : Colors.blue,
        ),
        title: Text(user['name']),
        subtitle: Text(user['kerberos']),
        trailing: Text(user['hostel'], style: const TextStyle(fontSize: 20)),
      )
    ]));
  }
}

class MealCard extends StatelessWidget {
  final API api;
  final Map<String, dynamic> mealToken;
  final bool active;
  const MealCard(
      {super.key,
      required this.mealToken,
      required this.api,
      required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: (mealToken['status'] == 'USED')
            ? Colors.red.shade100
            : Colors.green.shade100,
        leading:
            Text(mealToken['status'], style: const TextStyle(fontSize: 15)),
        title: Text(mealToken['meal_id']['name']),
        subtitle: Text(
            "${as1605.date(mealToken['meal_id']['start_time'])} - ${as1605.date(mealToken['meal_id']['end_time'])}"),
        trailing: Text((mealToken['enter_time'] == null)
            ? ''
            : 'Entered: ${as1605.date(mealToken['enter_time'])}'),
        onTap: active
            ? () => as1605.popup(context, title: "Meal", actions: [
                  ElevatedButton(
                      onPressed: (mealToken['status'] == 'USED')
                          ? null
                          : () async {
                              final result =
                                  await api.useMealToken(mealToken['_id']);
                              if (result == false) {
                                // ignore: use_build_context_synchronously
                                as1605.popup(context,
                                    title: "DO NOT ALLOW",
                                    content: const Icon(Icons.close,
                                        color: Colors.red));
                              } else {
                                // ignore: use_build_context_synchronously
                                as1605.popup(context,
                                    title: "ALLOW",
                                    content: const Icon(Icons.check,
                                        color: Colors.green, size: 20),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ok'))
                                    ]);
                              }
                            },
                      child: const Text('Scratch'))
                ])
            : null,
      ),
    );
  }
}
