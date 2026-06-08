import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TabelaPontuacaoComponent } from './tabela-pontuacao.component';

describe('TabelaPontuacaoComponent', () => {
  let component: TabelaPontuacaoComponent;
  let fixture: ComponentFixture<TabelaPontuacaoComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TabelaPontuacaoComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TabelaPontuacaoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
