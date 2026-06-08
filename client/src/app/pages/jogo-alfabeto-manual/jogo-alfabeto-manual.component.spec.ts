import { ComponentFixture, TestBed } from '@angular/core/testing';

import { JogoAlfabetoManualComponent } from './jogo-alfabeto-manual.component';

describe('JogoAlfabetoManualComponent', () => {
  let component: JogoAlfabetoManualComponent;
  let fixture: ComponentFixture<JogoAlfabetoManualComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [JogoAlfabetoManualComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(JogoAlfabetoManualComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
