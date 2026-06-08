import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaListaPersonagemComponent } from './tela-lista-personagem.component';

describe('TelaListaPersonagemComponent', () => {
  let component: TelaListaPersonagemComponent;
  let fixture: ComponentFixture<TelaListaPersonagemComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaListaPersonagemComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaListaPersonagemComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
