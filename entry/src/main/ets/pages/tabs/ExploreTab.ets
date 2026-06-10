import { DarkTheme } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';

/** 活动流数据 */
class ActivityItem {
  avatar: string = '';
  user: string = '';
  action: string = '';
  repo: string = '';
  time: string = '';

  constructor(a: string, u: string, act: string, r: string, t: string) {
    this.avatar = a;
    this.user = u;
    this.action = act;
    this.repo = r;
    this.time = t;
  }
}

/**
 * 探索 (Tab 3)
 */
@Component
export struct ExploreTab {
  private exploreStack: NavPathStack = new NavPathStack();

  private activities: ActivityItem[] = [
    new ActivityItem('A', 'alice', 'starred', 'flutter/flutter', '2h ago'),
    new ActivityItem('B', 'bob', 'forked', 'torvalds/linux', '5h ago'),
  ];

  @Builder
  explorePageMap(name: string, param: Object) {}

  build() {
    Navigation(this.exploreStack) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.page_title_explore'))
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          Row({ space: 12 }) {
            this.discoverItem('◈', '热门仓库')
            this.discoverItem('◈', '精选列表')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Divider()
            .color(DarkTheme.border)
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            Text('活动')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(DarkTheme.textPrimary)
              .layoutWeight(1)
            Text('▼')
              .fontSize(18)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .lineHeight(44)
          }
          .width('100%')
          .height(44)
          .padding({ left: 16, right: 16 })

          Column({ space: 8 }) {
            ForEach(this.activities, (item: ActivityItem, index: number) => {
              this.activityRow(item)
            }, (item: ActivityItem) => `${item.user}_${item.action}_${item.repo}`)
          }

          RepoCard({
            avatarChar: 'R',
            owner: 'reactjs',
            repo: 'react',
            description: 'The library for web and native user interfaces.',
            language: 'JavaScript',
            stars: 232000,
            isStarred: false
          })
            .margin({ left: 16, right: 16, top: 12 })

          Blank().height(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 32, bottom: 64 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor(DarkTheme.background)
    }
    .navDestination(this.explorePageMap)
    .backgroundColor(DarkTheme.background)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  activityRow(item: ActivityItem) {
    Row() {
      Text(item.avatar.toUpperCase())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .width(32)
        .height(32)
        .backgroundColor(DarkTheme.surfaceElevated)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .lineHeight(32)

      Column() {
        Row() {
          Text(item.user)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
          Text(` ${item.action} `)
            .fontSize(16)
            .fontColor(DarkTheme.textSecondary)
          Text(item.repo)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.accent)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        Text(item.time)
          .fontSize(12)
          .fontColor(DarkTheme.textTertiary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  discoverItem(icon: string, label: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .width(24)
        .height(24)
      Text(label)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
    }
    .width('48%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(DarkTheme.surface)
    .borderRadius(8)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {})
  }
}
