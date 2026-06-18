import { HttpClient } from './HttpClient';
import type { User } from '../models/User';

export class UserRepository {
  static getCurrentUser(): Promise<User> { return HttpClient.get<User>('/user'); }
  static getUser(username: string): Promise<User> { return HttpClient.get<User>('/users/' + username); }
  static getFollowers(username: string): Promise<Object[]> { return HttpClient.get<Object[]>('/users/' + username + '/followers?per_page=30'); }
  static getFollowing(username: string): Promise<Object[]> { return HttpClient.get<Object[]>('/users/' + username + '/following?per_page=30'); }
  static getReceivedEvents(username: string): Promise<Object[]> { return HttpClient.get<Object[]>('/users/' + username + '/received_events?per_page=10'); }
  static getOrgs(): Promise<Object[]> { return HttpClient.get<Object[]>('/user/orgs?per_page=30'); }
  static getContributions(username: string): Promise<Object> {
    const now: string = new Date().toISOString().substring(0, 10);
    const ly: Date = new Date();
    ly.setFullYear(ly.getFullYear() - 1);
    const from: string = ly.toISOString().substring(0, 10);
    const gql: string = 'query { user(login: "' + username + '") { contributionsCollection(from: "' + from + 'T00:00:00Z", to: "' + now + 'T23:59:59Z") { contributionCalendar { totalContributions weeks { contributionDays { contributionCount date } } } } } }';
    class GqlBody { query: string = ''; constructor(q: string) { this.query = q; } }
    return HttpClient.post<Object>('/graphql', new GqlBody(gql));
  }
}
