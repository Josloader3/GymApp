import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Gimnasio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.user == null) {
            return const Center(child: Text('No hay usuario logueado'));
          }

          return Column(
            children: [
              // Widgets específicos de tu home
              /*const WorkoutSummary(),
              const UpcomingSessions(),*/
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/workouts');
                },
                child: const Text('Mis Rutinas'),
              ),
            ],
          );
        },
      ),
      //bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
