import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaLoginUsuarioComponent } from './tela-login-usuario.component';

describe('TelaLoginUsuarioComponent', () => {
  let component: TelaLoginUsuarioComponent;
  let fixture: ComponentFixture<TelaLoginUsuarioComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaLoginUsuarioComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaLoginUsuarioComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
