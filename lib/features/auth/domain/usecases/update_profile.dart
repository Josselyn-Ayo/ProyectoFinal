import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UserEntity> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<void> call(UserEntity params) async {
    await repository.updateUser(params);
  }
}
