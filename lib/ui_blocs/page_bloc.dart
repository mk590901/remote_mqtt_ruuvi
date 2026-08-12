// page_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

enum PageStates { home, /*trace, db,*/ help, dashboard }

class PageState {
  final PageStates state;
  const PageState(this.state);
}

abstract class PageEvent {}
class HomeEvent extends PageEvent {}
class TraceEvent extends PageEvent {}
class DBEvent extends PageEvent {}
class HelpEvent extends PageEvent {}
class DashboardEvent extends PageEvent {}

class PageBloc extends Bloc<PageEvent, PageState> {
  PageBloc() : super(const PageState(PageStates.home)) {
    on<HomeEvent>((event, emit) => emit(const PageState(PageStates.home)));
    // on<TraceEvent>((event, emit) => emit(const PageState(PageStates.trace)));
    // on<DBEvent>((event, emit) => emit(const PageState(PageStates.db)));
    on<HelpEvent>((event, emit) => emit(const PageState(PageStates.help)));
    on<DashboardEvent>((event, emit) => emit(const PageState(PageStates.dashboard)));
  }
}
