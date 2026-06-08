import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Personagem } from 'src/app/model/Personagem';
import { UtilService } from 'src/app/service/util.service';

@Component({
  selector: 'app-personagem',
  templateUrl: './app-personagem.component.html',
  standalone: true,
  imports: [CommonModule, FormsModule],
  styleUrl: './app-personagem.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppPersonagemComponent implements OnInit {

  personagem: Personagem;

  async ngOnInit() {
    this.personagem = UtilService.getPersonagem();
  }

}
