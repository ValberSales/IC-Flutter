import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { UtilService } from './service/util.service';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);

  if (UtilService.isLoggedIn()) {
    return true;
  } else {
    router.navigate(['/login'], { queryParams: { returnUrl: state.url } });
    return false;
  }
};