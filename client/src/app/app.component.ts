import { Component, OnInit, Renderer2 } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { ConfirmationService, MenuItem, MessageService, PrimeNGConfig } from 'primeng/api';
import { Subscription } from 'rxjs';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { ELocalStorageKeys, UtilService } from './service/util.service';

export const main: { msg: MessageService } = { msg: null };

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: '../styles.scss',
  providers: [MessageService, DialogService, ConfirmationService],
})
export class AppComponent implements OnInit {
  private routeSubscription: Subscription;

  title = 'Jogo Libras';

  dockItens: MenuItem[] = [
    {
      label: 'Início',
      icon: 'https://cdn-icons-png.freepik.com/256/10751/10751558.png?semt=ais_hybrid',
      command: () => {
        this.router.navigateByUrl('');
      },
    },
    {
      label: 'Jogo Letras',
      icon: 'https://cdn-icons-png.flaticon.com/512/7300/7300779.png',
      command: () => {
        this.router.navigateByUrl('/alfabeto-manual');
      },
    },
    {
      label: 'Jogo Memória',
      icon: 'https://cdn-icons-png.flaticon.com/512/6168/6168860.png',
      command: () => {
        this.router.navigateByUrl('/jogo-memoria');
      },
    },
    {
      label: 'Jogo Palavras',
      icon: 'https://cdn-icons-png.flaticon.com/512/8541/8541715.png',
      command: () => {
        this.router.navigateByUrl('jogo-palavra');
      },
    },
    {
      label: 'Jogo Adivinhação',
      icon: 'https://cdn-icons-png.flaticon.com/512/10199/10199730.png',
      command: () => {
        this.router.navigateByUrl('/adivinhacao');
      },
    },
  ];

  allowedRoutes = ['/adivinhacao', '/alfabeto-manual', '/jogo-memoria', '/jogo-palavra', '/', '/sobre'];

  constructor(
    public router: Router,
    private primengConfig: PrimeNGConfig,
    private renderer: Renderer2,
    public msg: MessageService
  ) {
    var r: any = document.getElementById('app-jogo-libras');
    r.style.setProperty('zoom', 'var(--zoom)');
    this.onResize();
    window.onresize = (evt) => {
      this.onResize();
    }
    main.msg = this.msg;
  }

  onResize() {
    var r: any = document.querySelector(':root');
    if (window.innerWidth > window.innerHeight && window.innerWidth < 730) {
      r.style.setProperty('--zoom', '0.45');
    } else if (window.innerWidth > window.innerHeight && window.innerWidth < 900) {
      r.style.setProperty('--zoom', '0.63');
    } else if (window.innerWidth > window.innerHeight && window.innerWidth < 1024) {
      r.style.setProperty('--zoom', '0.65');
    } else if (window.innerWidth > window.innerHeight && window.innerWidth < 1290) {
      r.style.setProperty('--zoom', '0.75');
    } else if (window.innerWidth > window.innerHeight && window.innerWidth < 1368) {
      r.style.setProperty('--zoom', '0.8');
    } else {
      r.style.setProperty('--zoom', '1');
    }

  }

  ngOnInit(): void {
    this.primengConfig.ripple = true;

    this.routeSubscription = this.router.events.subscribe((event) => {
      if (event instanceof NavigationEnd) {
        if (this.allowedRoutes.includes(event.urlAfterRedirects)) {
          this.renderer.addClass(document.body, 'custom-background');
        } else {
          this.renderer.removeClass(document.body, 'custom-background');
        }
      }
    });

    if(localStorage.getItem(ELocalStorageKeys.LAST_LOGIN)) {
      const lastLogin = new Date(localStorage.getItem(ELocalStorageKeys.LAST_LOGIN));
      const now = new Date();
      const diffInMs = now.getTime() - lastLogin.getTime();
    
      if (diffInMs > 24 * 60 * 60 * 1000) {
        UtilService.loggout();
      }
    }
  }

  isDockVisible(): boolean {
    const visible = this.allowedRoutes.filter((a) => a != '/sobre')
    return visible.includes(this.router.url);
  }
}
