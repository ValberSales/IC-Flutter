import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JogoAdivinhacaoComponent } from './jogo-adivinhacao.component';

describe('JogoAdivinhacaoComponent', () => {
  let component: JogoAdivinhacaoComponent;
  let fixture: ComponentFixture<JogoAdivinhacaoComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [JogoAdivinhacaoComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(JogoAdivinhacaoComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
