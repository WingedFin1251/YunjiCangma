import { HttpClient } from './HttpClient';
import type { CheckSuitesResult, CheckRunsResult, WorkflowRunsResult } from '../models/CheckRunModels';

/** GitHub Actions / Check Run 相关端点 */
export class CheckRunRepository {
  /** 获取仓库的 Check Suite 列表（按分支/提交） */
  static getCheckSuites(owner: string, repo: string, ref: string): Promise<CheckSuitesResult> {
    return HttpClient.get<CheckSuitesResult>('/repos/' + owner + '/' + repo + '/commits/' + ref + '/check-suites');
  }

  /** 获取 Check Suite 中的 Check Run 列表 */
  static getCheckRuns(owner: string, repo: string, suiteId: number): Promise<CheckRunsResult> {
    return HttpClient.get<CheckRunsResult>('/repos/' + owner + '/' + repo + '/check-suites/' + suiteId.toString() + '/check-runs');
  }

  /** 获取 Workflow Runs 列表（按分支筛选） */
  static getWorkflowRuns(owner: string, repo: string, branch: string): Promise<WorkflowRunsResult> {
    return HttpClient.get<WorkflowRunsResult>('/repos/' + owner + '/' + repo + '/actions/runs?branch=' + branch + '&per_page=10');
  }
}