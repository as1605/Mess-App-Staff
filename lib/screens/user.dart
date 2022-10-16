import 'package:flutter/material.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';

class UserScreen extends StatefulWidget {
  final API api;
  final String kerberos;
  final String? token;
  const UserScreen({
    super.key,
    required this.api,
    required this.kerberos,
    this.token,
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
    if (widget.token == null) {
      userProfile = await widget.api.verifyWithoutToken(widget.kerberos);
    } else {
      userProfile =
          await widget.api.verifyToken(widget.kerberos, widget.token!);
    }
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
        appBar: AppBar(title: const Text("User Details")),
        body: (msg == null)
            ? ListView(
                children: [
                      (user == null)
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : UserCard(user: user!),
                      Text(activeMeals == []
                          ? 'No Active Meals'
                          : 'Active Meals')
                    ] +
                    activeMeals
                        .map((e) => MealCard(mealToken: e, api: widget.api))
                        .toList() +
                    [Text(allMeals == [] ? 'No Meals' : 'All Meals')] +
                    allMeals
                        .map((e) => MealCard(mealToken: e, api: widget.api))
                        .toList())
            : Text(msg!));
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: user['isActive'] == true ? Colors.green : Colors.blue,
      ),
      title: Text(user['name']),
      subtitle: Text(user['kerberos']),
      trailing: Text(user['hostel']),
    );
  }
}

class MealCard extends StatelessWidget {
  final API api;
  final Map<String, dynamic> mealToken;
  const MealCard({super.key, required this.mealToken, required this.api});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(mealToken['status']),
      title: Text(mealToken['meal_id']['name']),
      subtitle: Text(
          "${as1605.date(mealToken['meal_id']['start_time'])} - ${as1605.date(mealToken['meal_id']['end_time'])}"),
      trailing: Text((mealToken['enter_time'] == null)
          ? ''
          : 'Entered: ${as1605.date(mealToken['enter_time'])}'),
      onTap: () => as1605.popup(context, title: "Meal", actions: [
        ElevatedButton(
            onPressed: (mealToken['status'] == 'USED')
                ? null
                : () {
                    final result = api.useMealToken(mealToken['_id']);
                    if (result == false) {
                      as1605.popup(context,
                          title: "DO NOT ALLOW",
                          content: const Icon(Icons.close, color: Colors.red));
                    } else {
                      as1605.popup(context,
                          title: "ALLOW",
                          content: const Icon(Icons.check, color: Colors.green),
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
      ]),
    );
  }
}
