import { HttpClient } from './HttpClient';

/** GitHub Actions / Check Run 相关端点 */
export class CheckRunRepository {
  /** 获取仓库的 Check Suite 列表（按分支/提交） */
  static getCheckSuites(owner: string, repo: string, ref: string): Promise<Object> {
    return HttpClient.get<Object>('/repos/' + owner + '/' + repo + '/commits/' + ref + '/check-suites');
  }

  /** 获取 Check Suite 中的 Check Run 列表 */
  static getCheckRuns(owner: string, repo: string, suiteId: number): Promise<Object> {
    return HttpClient.get<Object>('/repos/' + owner + '/' + repo + '/check-suites/' + suiteId.toString() + '/check-runs');
  }
}
