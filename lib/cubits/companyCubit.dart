
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injazathr/data/models/company.dart';
import 'package:injazathr/data/repositories/companyRepository.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyFetchInProgress extends CompanyState {}

class CompanyFetchSuccess extends CompanyState {
  late final List<Company> company;

  CompanyFetchSuccess(this.company);
}

class CompanyFetchFailure extends CompanyState {
  late final String errorMessage;

  CompanyFetchFailure(this.errorMessage);
}

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _companyRepository;

  CompanyCubit(this._companyRepository) : super(CompanyInitial());

  void updateState(CompanyState updatedState) {
    emit(updatedState);
  }

  void fetchSchools() async {
    emit(CompanyFetchInProgress());
    try {
      emit(CompanyFetchSuccess(await _companyRepository.fetchSchools()));
    } catch (e) {
      emit(CompanyFetchFailure(e.toString()));
    }
  }

  List<Company> getSchools() {
    if (state is CompanyFetchSuccess) {
      return (state as CompanyFetchSuccess).company;
    }
    return [];
  }
}
