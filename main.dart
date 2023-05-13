import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class NamaId {
  String id;
  String nama;
  NamaId({required this.id, required this.nama});
}

class PopulasiState {
  final List<NamaId> listPop;

  PopulasiState({required this.listPop});
}


String dropdownValue = "1";

class PopulasiCubit extends Cubit<PopulasiState> {
  PopulasiCubit() : super(PopulasiState(listPop: []));

  Future<void> fetchData() async {
    String coba = "1";
    final response = await http.get(Uri.parse(
        "http://178.128.17.76:8000/jenis_pinjaman/3"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      final List<NamaId> listPop = data
          .map<NamaId>((json) => NamaId(
              id: json["id"], nama: json["nama"]))
          .toList();

      emit(PopulasiState(listPop: listPop));
    } else {
      throw Exception('Gagal load');
    }
  }
}


void main() {
  runApp (MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 3 Provis',
      home: BlocProvider(
        create: (context) => PopulasiCubit()..fetchData(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz 3 Provis'),
      ),
      body: Center(
        child:
          BlocBuilder<PopulasiCubit, PopulasiState>(
          builder: (context, state) {
            if (state.listPop.isEmpty) {
              return const CircularProgressIndicator();
            }

            return Center(
              child: ListView.builder(
                itemCount: state.listPop.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.listPop[index].nama),
                    subtitle: Text(state.listPop[index].id),
                    onTap: () async {
                      final response = await http.get(Uri.parse(
                          "http://178.128.17.76:8000/detil_jenis_pinjaman/${state.listPop[index].id}"));
                      if (response.statusCode == 200) {
                        final idDetil = jsonDecode(response.body)["id"];
                        final namaDetil = jsonDecode(response.body)["nama"];
                        final bungaDetil = jsonDecode(response.body)["bunga"];
                        final syariahDetil = jsonDecode(response.body)["is_syariah"];
                        // Menampilkan detail pada dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(state.listPop[index].nama),
                              content: Text("ID: $idDetil, Nama: $namaDetil, Bunga: $bungaDetil, Apakah Syariah? $syariahDetil"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Tutup'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        throw Exception('Gagal load');
                      }
                    },
                  );
                },
                // alignment: Alignment.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

