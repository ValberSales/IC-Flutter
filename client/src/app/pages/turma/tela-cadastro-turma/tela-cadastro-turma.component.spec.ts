import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaCadastroTurmaComponent } from './tela-cadastro-turma.component';

describe('TelaCadastroTurmaComponent', () => {
  let component: TelaCadastroTurmaComponent;
  let fixture: ComponentFixture<TelaCadastroTurmaComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaCadastroTurmaComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaCadastroTurmaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
