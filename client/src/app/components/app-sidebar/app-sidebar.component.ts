import { Component, Input, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { LayoutService } from 'src/app/service/app.layout.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './app-sidebar.component.html',
  styleUrl: './app-sidebar.component.scss',
})
export class AppSidebarComponent implements OnInit {

  @Input()
  model: MenuItem[] = [];

  constructor(public layoutService: LayoutService) {}

  ngOnInit() {

  }
}
