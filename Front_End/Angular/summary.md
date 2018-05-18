Creat
你使用 CLI 创建了第二个组件 HeroesComponent。
    ng generate component heroes
你把 HeroesComponent 添加到了壳组件 AppComponent 中，以便显示它。
  app.component.html <app-heros></app-heros>
你使用 UppercasePipe 来格式化英雄的名字。
  heros.component.html <h2>{{hero.name | uppercase}} Details</h2>
你用 ngModel 指令实现了双向数据绑定。
  <input [(ngModel)]="hero.name" placeholder="name">
你知道了 AppModule。
  添加元数据的地方，Angular 需要知道如何把应用程序的各个部分组合到一起，以及该应用需要哪些其它文件和库。 这些信息被称为元数据（metadata）
你把 FormsModule 导入了 AppModule，以便 Angular 能识别并应用 ngModel 指令。
  app.module.ts import { FormsModule } from '@angular/forms'; // <-- NgModel lives here
  imports: [
    BrowserModule,
    FormsModule
  ],
你知道了把组件声明到 AppModule 是很重要的，并认识到 CLI 会自动帮你声明它。
  @NgModule({ declarations: [AppComponent,HerosComponent],。。。})
 

Display
英雄指南应用在一个主从视图中显示了英雄列表。
  click事件  html <li *ngFor="let hero of heroes" (click)="onSelect(hero)">
            ts onSelect(hero: Hero): void {this.selectedHero = hero;}
用户可以选择一个英雄，并查看该英雄的详情。
  <input [(ngModel)]="selectedHero.name" placeholder="name">
你使用 *ngFor 显示了一个列表。
  <li *ngFor="let hero of heroes" [class.selected]='hero === selectHero' (click)="onSelect(hero)">
你使用 *ngIf 来根据条件包含或排除了一段 HTML。
  <div *ngIf='selectHero'></div>
你可以用 class 绑定来切换 CSS 的样式类。
  [class.selected]='hero === selectHero' 


Master/Detail
你创建了一个独立的、可复用的 HeroDetailComponent 组件。
  ng generate component hero-detail
你用属性绑定语法来让父组件 HeroesComponent 可以控制子组件 HeroDetailComponent。
  import { Hero } from '../hero';
  @Input() hero: Hero;
你用 @Input 装饰器来让 hero 属性可以在外部的 HeroesComponent 中绑定
  <app-hero-detail [hero]="selectedHero"></app-hero-detail>
  import { Input } from '@angular/core';


Service
你把数据访问逻辑重构到了 HeroService 类中。
  组件不应该直接获取或保存数据， 它们应该聚焦于展示数据，而把数据访问的职责委托给某个服务
你在根模块 AppModule 中提供了 HeroService 服务，以便在别处可以注入它。
  ng generate service hero --module=app //not insert automatically
  import { HeroService } from './hero.service';
  @NgModule({providers: [HeroService]})
你使用 Angular 依赖注入机制把它注入到了组件中。
  heroes.component.ts: import { HeroService } from '../hero.service';
  constructor(private heroService: HeroService) { } 
你给 HeroService 中获取数据的方法提供了一个异步的函数签名。
  服务是在多个“互相不知道”的类之间共享信息的好办法
  回调函数，可以返回 Promise（承诺），也可以返回 Observable（可观察对象）
你发现了 Observable 以及 RxJS 库。
  import { Observable, of } from 'rxjs';
你使用 RxJS 的 of() 方法返回了一个模拟英雄数据的可观察对象 (Observable<Hero[]>)。
  getHeroes(): Observable<Hero[]> {
    this.messageService.add('HeroService: fetched heroes');
    return of(HEROES);
  }
在组件的 ngOnInit 生命周期钩子中调用 HeroService 方法，而不是构造函数中。
  让构造函数保持简单，只做初始化操作，比如把构造函数的参数赋值给属性。 构造函数不应该做任何事
你创建了一个 MessageService，以便在类之间实现松耦合通讯。
  ng generate service message --module=app
  HeroService 连同注入到它的服务 MessageService 一起，注入到了组件中。
  hero.service.ts: import { MessageService } from './message.service';
  constructor(private messageService: MessageService) { }
  export class HeroesComponent implements OnInit {
    constructor(private heroService: HeroService) {}
    ngOnInit() {this.getHeroes();}
    getHeroes(): void {this.heroService.getHeroes().subscribe(heroes => this.heroes = heroes);}
  }


Router
添加了 Angular 路由器在各个不同组件之间导航。
  ng generate module app-routing --flat --module=app
你使用一些 <a> 链接和一个 <router-outlet> 把 AppComponent 转换成了一个导航用的壳组件。
  app.component.html
  <nav>
      <a routerLink="/dashboard">DashBoard</a>
      <a routerLink="/heroes">Heroes</a>
  </nav>
  <router-outlet></router-outlet>
你在 AppRoutingModule 中配置了路由器。
  const routes: Routes = [
    { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
    { path: 'heroes', component: HeroesComponent },
    { path: 'dashboard', component: DashboardComponent },
    { path: 'detail/:id', component: HeroDetailComponent },
  ];
  @NgModule({
    imports: [RouterModule.forRoot(routes)]...
  })
你定义了一些简单路由、一个重定向路由和一个参数化路由。
  { path: 'heroes', component: HeroesComponent },
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'detail/:id', component: HeroDetailComponent },
你在 <a> 元素中使用了 routerLink 指令。
  dashboard.component.html&heroes.component.html <a routerLink="/detail/{{hero.id}}">
你把一个紧耦合的主从视图重构成了带路由的详情视图。
  hero-detail.component.ts
  export class HeroDetailComponent implements OnInit {
    @Input() hero: Hero;
    constructor(
      private route: ActivatedRoute,
      private heroService: HeroService,
      private location: Location) { }
    ngOnInit() {
      this.getHero();
    }
    getHero(): void {
      const id = +this.route.snapshot.paramMap.get('id');
      this.heroService.getHero(id)
        .subscribe(hero => this.hero = hero);
    }
  }
你使用路由链接参数来导航到所选英雄的详情视图。
  getHero(): void {
    const id = +this.route.snapshot.paramMap.get('id');
    this.heroService.getHero(id)
      .subscribe(hero => this.hero = hero);
  }
在多个组件之间共享了 HeroService 服务。
  hero.service.ts//读取数据的服务
  use: dashboard.component.ts&heroes.component.ts&hero-detail.component.ts


HTTP
你添加了在应用程序中使用 HTTP 的必备依赖。

你重构了 HeroService，以通过 web API 来加载英雄数据。

你扩展了 HeroService 来支持 post()、put() 和 delete() 方法。

你修改了组件，以允许用户添加、编辑和删除英雄。

你配置了一个内存 Web API。

你学会了如何使用“可观察对象”。