import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaPerfilUsuarioComponent } from './tela-perfil-usuario.component';

describe('TelaPerfilUsuarioComponent', () => {
  let component: TelaPerfilUsuarioComponent;
  let fixture: ComponentFixture<TelaPerfilUsuarioComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaPerfilUsuarioComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaPerfilUsuarioComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
