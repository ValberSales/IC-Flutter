import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PainelPontuacaoComponent } from './painel-pontuacao.component';

describe('PainelPontuacaoComponent', () => {
  let component: PainelPontuacaoComponent;
  let fixture: ComponentFixture<PainelPontuacaoComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PainelPontuacaoComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PainelPontuacaoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
