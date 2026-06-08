import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JogoPalavrasComponent } from './jogo-palavras.component';

describe('JogoPalavrasComponent', () => {
  let component: JogoPalavrasComponent;
  let fixture: ComponentFixture<JogoPalavrasComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [JogoPalavrasComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(JogoPalavrasComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
