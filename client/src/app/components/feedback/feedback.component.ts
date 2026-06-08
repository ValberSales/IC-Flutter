import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  Output,
  SimpleChanges,
} from '@angular/core';
import { EFeedback, ETipoFeedback } from 'src/app/model/enum/EFeedback';

@Component({
  selector: 'app-feedback',
  templateUrl: './feedback.component.html',
  styleUrl: './feedback.component.scss',
})
export class FeedbackComponent {
  @Output()
  clearFeedback: EventEmitter<void> = new EventEmitter<void>();

  @Input()
  scale: number = 1;

  @Input()
  set tipo(value: ETipoFeedback) {
    this._tipo = value;
    this.changeMessage();
  }

  private timeoutId: any;
  private _tipo: ETipoFeedback = ETipoFeedback.VAZIO;

  get tipo(): ETipoFeedback {
    return this._tipo;
  }

  changeMessage() {
    if (this._tipo === ETipoFeedback.VAZIO) {
      return;
    }

    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }

    this.timeoutId = setTimeout(() => {
      this._tipo = ETipoFeedback.VAZIO;
      this.clearFeedback.emit();
      this.timeoutId = null;
    }, 2000);
  }
}
