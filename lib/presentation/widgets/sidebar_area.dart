import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/documentation_bloc.dart';
import '../../application/bloc/documentation_state.dart';
import 'sidebar_navigation.dart';

/// Sidebar area wrapper with animated loading overlay
class SidebarArea extends StatelessWidget {
  final String currentTheme;

  const SidebarArea({
    super.key,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentationBloc, DocumentationState>(
      builder: (context, state) {
        final isLoadingTree = state is DocumentationInitial;

        return Stack(
          children: [
            // Sidebar Navigation
            SidebarNavigation(currentTheme: currentTheme),

            // Animated Loading Overlay
            AnimatedOpacity(
              opacity: isLoadingTree ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !isLoadingTree,
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
