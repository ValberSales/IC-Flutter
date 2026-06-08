import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PontuacaoComponent } from './pontuacao.component';

describe('PontuacaoComponent', () => {
  let component: PontuacaoComponent;
  let fixture: ComponentFixture<PontuacaoComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PontuacaoComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PontuacaoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
