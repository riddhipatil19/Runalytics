import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:runn_track/api/api_run.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> myRuns = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyRuns();
  }

  ApiRun service = ApiRun();

  void getMyRuns() async {
    final token = await SharedPrefHelper.getToken();
    final runs = await service.getMyRuns(token: token!);
    setState(() {
      myRuns = runs;
      isLoading = false;
    });
    print(myRuns);
  }

  bool isDeleting = false;

  void deleteRun(int id) async {
    setState(() {
      isDeleting = true;
    });
    final token = await SharedPrefHelper.getToken();
    final response = await service.deleteRunById(id: id, token: token!);
    if (response['status'] == 200) {
      Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isDeleting = false;
      });
      getMyRuns();
    } else {
      Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isDeleting = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    return duration.toString().split('.').first;
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myRuns.isEmpty
              ? const Center(
                  child: Text(
                    "🏃 Go for a run buddy!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 40, 12, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "My Runs",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: height,
                          child: RefreshIndicator(
                            onRefresh: () async => getMyRuns(),
                            child: ListView.builder(
                              itemCount: myRuns.length,
                              itemBuilder: (context, index) {
                                final run = myRuns[index];
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.only(bottom: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.directions_run,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${run['totalDistanceKm']} km",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "${run['averagePace'].toStringAsFixed(2)} min/km",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.timer,
                                                color: Colors.redAccent),
                                            const SizedBox(width: 8),
                                            Text(
                                                "Duration: ${_formatDuration(run['durationSeconds'])}"),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.green),
                                            const SizedBox(width: 8),
                                            Text(
                                                "Date: ${_formatDate(run['startTime'])}"),
                                            const Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  deleteRun(run['id']);
                                                },
                                                icon: Icon(Icons.delete,
                                                    color: isDeleting
                                                        ? Colors.grey
                                                        : Colors.red))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
