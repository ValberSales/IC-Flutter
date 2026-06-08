import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaCadastroPalavraComponent } from './tela-cadastro-palavra.component';

describe('TelaCadastroPalavraComponent', () => {
  let component: TelaCadastroPalavraComponent;
  let fixture: ComponentFixture<TelaCadastroPalavraComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaCadastroPalavraComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaCadastroPalavraComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
