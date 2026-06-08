import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaListaPalavraComponent } from './tela-lista-palavra.component';

describe('TelaListaPalavraComponent', () => {
  let component: TelaListaPalavraComponent;
  let fixture: ComponentFixture<TelaListaPalavraComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaListaPalavraComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaListaPalavraComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
