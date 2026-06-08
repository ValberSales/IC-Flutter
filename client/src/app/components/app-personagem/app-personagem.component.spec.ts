import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AppPersonagemComponent } from './app-personagem.component';

describe('AppPersonagemComponent', () => {
  let component: AppPersonagemComponent;
  let fixture: ComponentFixture<AppPersonagemComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppPersonagemComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AppPersonagemComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
