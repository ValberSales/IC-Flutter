import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MenuAvatarComponent } from './menu-avatar.component';

describe('MenuAvatarComponent', () => {
  let component: MenuAvatarComponent;
  let fixture: ComponentFixture<MenuAvatarComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MenuAvatarComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MenuAvatarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
