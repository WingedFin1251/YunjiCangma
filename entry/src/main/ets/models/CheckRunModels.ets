/** Check Suite（GET /repos/{o}/{r}/commits/{ref}/check-suites 的 suite 项） */
export interface CheckSuite {
  id: number;
  head_branch: string;
  head_sha: string;
  status: string;
  conclusion: string | null;
  created_at: string;
  updated_at: string;
}

export interface CheckSuitesResult {
  total_count: number;
  check_suites: CheckSuite[];
}

/** Check Run（GET /check-suites/{id}/check-runs 的 run 项） */
export interface CheckRun {
  id: number;
  name: string;
  head_branch: string;
  head_sha: string;
  status: string;
  conclusion: string | null;
  started_at: string;
  completed_at: string;
  html_url: string;
}

export interface CheckRunsResult {
  total_count: number;
  check_runs: CheckRun[];
}

/** Workflow Run（GET /actions/runs 的 run 项） */
export interface WorkflowRun {
  id: number;
  name: string;
  head_branch: string;
  head_sha: string;
  status: string;
  conclusion: string | null;
  run_started_at: string;
  created_at: string;
  updated_at: string;
  html_url: string;
}

export interface WorkflowRunsResult {
  total_count: number;
  workflow_runs: WorkflowRun[];
}