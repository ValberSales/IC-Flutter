import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaCadastroPersonagemComponent } from './tela-cadastro-personagem.component';

describe('TelaCadastroPersonagemComponent', () => {
  let component: TelaCadastroPersonagemComponent;
  let fixture: ComponentFixture<TelaCadastroPersonagemComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaCadastroPersonagemComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaCadastroPersonagemComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
