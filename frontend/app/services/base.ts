import server from 'app/server';
import {
  EmpireCreateParams,
  EmpireCreateResponse,
  EmpireFetchCaptchaParams,
  EmpireFetchCaptchaResponse,
  EmpireGetStatusParams,
  EmpireGetStatusResponse,
  EmpireLoginParams,
  EmpireLoginResponse,
  EmpireLogoutParams,
  EmpireLogoutResponse,
} from 'app/interfaces';

class ServiceBase {
  call(
    module: 'empire',
    method: 'create',
    params: EmpireCreateParams,
    addSession?: boolean
  ): Promise<EmpireCreateResponse>;

  call(
    module: 'empire',
    method: 'get_status',
    params: EmpireGetStatusParams,
    addSession?: boolean
  ): Promise<EmpireGetStatusResponse>;

  call(
    module: 'empire',
    method: 'fetch_captcha',
    params: EmpireFetchCaptchaParams,
    addSession?: boolean
  ): Promise<EmpireFetchCaptchaResponse>;

  call(
    module: 'empire',
    method: 'login',
    params: EmpireLoginParams,
    addSession?: boolean
  ): Promise<EmpireLoginResponse>;

  call(
    module: 'empire',
    method: 'logout',
    params: EmpireLogoutParams,
    addSession?: boolean
  ): Promise<EmpireLogoutResponse>;

  call(module: string, method: string, params: any, addSession = true): Promise<any> {
    return new Promise((resolve, reject) => {
      server.call({
        module,
        method,
        params,
        addSession,
        success: (res: any) => {
          resolve(res);
        },
        error: (error: any) => {
          reject(error);
        },
      });
    });
  }
}

export default ServiceBase;
