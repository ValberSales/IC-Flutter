import { Component, ElementRef, Input, OnInit, ViewChild } from '@angular/core';
import { MenuItem, MessageService } from 'primeng/api';
import { FileUpload, UploadEvent } from 'primeng/fileupload';
import { InputOtp } from 'primeng/inputotp';
import { Palavra } from 'src/app/model/Palavra';
import { PalavraService } from 'src/app/service/palavra.service';

@Component({
  selector: 'app-tela-cadastro-palavra',
  templateUrl: './tela-cadastro-palavra.component.html',
  styleUrl: './tela-cadastro-palavra.component.scss',
})
export class TelaCadastroPalavraComponent implements OnInit {
  @ViewChild('fileUpload')
  fileUpload!: FileUpload;

  @ViewChild('inputOtp') 
  inputOtp!: InputOtp;

  existsInputOtp: boolean = true;

  @Input()
  palavra: Palavra = new Palavra();

  tiposPalavra: MenuItem = [
    {
      label: 'Jogo Adivinhação',
      value: 'JOGO_ADIVINHACAO',
    },
    {
      label: 'Jogo Palavras',
      value: 'JOGO_PALAVRAS',
    },
  ];

  opcao1: string;
  opcao2: string;
  opcao3: string;
  opcao4: string;
  opcao5: string;

  constructor(public service: PalavraService, public message: MessageService) {}

  ngOnInit(): void {
    if (!this.palavra) {
      this.palavra = new Palavra();
    } else if(this.palavra?.id && this.palavra.tipo == 'JOGO_PALAVRAS') {
      this.opcao1 = this.palavra?.opcoes[0];
      this.opcao2 = this.palavra?.opcoes[1];
      this.opcao3 = this.palavra?.opcoes[2];
      this.opcao4 = this.palavra?.opcoes[3];
      this.opcao5 = this.palavra?.opcoes[4];
    }
  }

  onUpload(event: any): void {
    const file = event.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        this.palavra.imagem = reader.result as string;
      };

      reader.onerror = (error) => {
        console.error('Erro ao ler o arquivo:', error);
      };

      reader.readAsDataURL(file);
    }
  }

  doValidate(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      if (!this.palavra?.descricao || this.palavra?.descricao.length <= 3) {
        this.message.add({
          severity: 'info',
          summary: 'Aviso',
          detail: 'A palavra deve ter mais que 3 letras!',
        });
        return reject();
      }
      if(this.palavra.tipo == 'JOGO_PALAVRAS') {
        if(!this.opcao1 || !this.opcao2 || !this.opcao3 || !this.opcao4 || !this.opcao5) {
          this.message.add({
            severity: 'info',
            summary: 'Aviso',
            detail: 'Preencha todas as opções!',
          });
          return reject();
        }
      }
      if (!this.palavra?.imagem) {
        this.message.add({
          severity: 'info',
          summary: 'Aviso',
          detail: 'Por favor, selecione uma imagem!',
        });
        return reject();
      }
      return resolve();
    });
  }

  save() {
    this.doValidate()
      .then(() => {
        this.palavra.opcoes = [
          this.opcao1, this.opcao2, this.opcao3, this.opcao4, this.opcao5
        ]
        this.service.save(this.palavra).subscribe({
          next: (value) => {
            this.message.add({
              severity: 'success',
              summary: 'Sucesso',
              detail: 'Sua palavra foi cadastrada!',
            });
            this.palavra = new Palavra();
            this.fileUpload.clear();

            this.existsInputOtp = false;
            setTimeout(() => {
              this.existsInputOtp = true;
            }, 1)
          },
          error: (err) => {
            console.log(err);
            this.message.add({
              severity: 'error',
              summary: 'Erro',
              detail: 'Ocorreu um erro ao salvar',
            });
          },
        });
      })
      .catch(() => {});
  }
}
