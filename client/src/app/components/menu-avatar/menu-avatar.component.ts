import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DynamicDialogRef } from 'primeng/dynamicdialog';

@Component({
  selector: 'app-menu-avatar',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './menu-avatar.component.html',
  styleUrl: './menu-avatar.component.scss',
})
export class MenuAvatarComponent {

  constructor(
    private modal: DynamicDialogRef
  ) {}

  avatares: string[] = [
    'assets/avatar/avatar_1.jpg',
    'assets/avatar/avatar_2.jpg',
    'assets/avatar/avatar_3.jpg',
    'assets/avatar/avatar_4.jpg',
    'assets/avatar/avatar_5.jpg',
    'assets/avatar/avatar_6.jpg',
    'assets/avatar/avatar_7.jpg',
    'assets/avatar/avatar_8.jpg',
    'assets/avatar/avatar_9.jpg',
  ];

  selectAvatar(src: string) {
    this.modal.close(src);
  }
}
