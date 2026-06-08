import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelaListaTurmaComponent } from './tela-lista-turma.component';

describe('TelaListaTurmaComponent', () => {
  let component: TelaListaTurmaComponent;
  let fixture: ComponentFixture<TelaListaTurmaComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelaListaTurmaComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TelaListaTurmaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
